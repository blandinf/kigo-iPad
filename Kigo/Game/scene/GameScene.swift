//
//  GameScene.swift
//  SpaceGame
//
//  Created by Florian on 17/04/2020.
//  Copyright © 2020 blandinf. All rights reserved.
//

import SpriteKit
import AVKit

enum CollisionType: UInt32 {
    case player = 1
    case bonus = 2
    case enemy = 4
}

enum BonusTypes: String {
    case STONE = "stone"
    case BALLOON = "balloon"
    case FLASHLIGHT = "flashlight"
    case ICE = "ice"
}

class GameScene: SKScene {
    let PLAYER_HEIGHT: CGFloat = 30.0
    let PLAYER_WIDTH: CGFloat = 75.0
    
    let player = SKSpriteNode(imageNamed: "bird-step01")
    
    let waves = Bundle.main.decode([Wave].self, from: "waves.json")
    let enemyTypes = Bundle.main.decode([EnemyType].self, from: "enemy-types.json")
    let bonusTypes = Bundle.main.decode([BonusType].self, from: "bonus-types.json")
    let gameOverImg = SKSpriteNode(imageNamed: "gameOver")
    var avPlayer = AVPlayer()
    var birdFrozen = false
    var birdTouches: Int = 0
    var displaySize = UIScreen.main.bounds
    
    var isPlayerAlive = true
    var levelNumber = 0
    var waveNumber = 0
    var playerShield = 3
    var beginning = true
    var gameDelegate: GameDelegate?
    
    let positions = Array(stride(from: 0, through: 320, by: 80))
    
    override func didMove(to view: SKView) {
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        //player first position
        player.name = "player"
        player.position.x = frame.minX + PLAYER_WIDTH + 100
        player.zPosition = 1
        addChild(player)
        
        player.size = CGSize(width: 100, height: 100)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        player.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.bonus.rawValue
        player.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.bonus.rawValue
        player.physicsBody?.isDynamic = false
        
        animatePlayer()
        
//        launchVideoInLoop()
    }
    
    func animatePlayer() {
        var textures: [SKTexture] = []
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "bird-step\(i)"))
        }
        textures.append(textures[2])
        textures.append(textures[1])
        
        var birdAnimation = SKAction.animate(with: textures, timePerFrame: 0.1)
        
        player.run(SKAction.repeatForever(birdAnimation))
    }
    
    
    func launchVideoInLoop() {
//        let videoNode: SKVideoNode? = {
//            guard let urlString = Bundle.main.path(forResource: "video", ofType: "mp4") else { return nil }
//            let url = URL(fileURLWithPath: urlString)
//            let item = AVPlayerItem(url: url)
//            avPlayer = AVPlayer(playerItem: item)
//
//            return SKVideoNode(avPlayer: avPlayer)
//        }()
//
//        videoNode?.position = CGPoint( x: frame.midX, y: frame.midY)
//        videoNode?.zPosition = 0
//        addChild((videoNode)!)
//        avPlayer.play()
//
//        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem, queue: nil)
//        { notification in
//            self.avPlayer.seek(to: CMTime.zero)
//            self.avPlayer.play()
//            print("reset Video")
//        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !birdFrozen {
            for touch in touches {
                let location = touch.location(in: self)
                player.position.y = location.y
                
                if player.position.y + PLAYER_HEIGHT > frame.maxY {
                    player.position.y = frame.maxY - PLAYER_HEIGHT
                } else if player.position.y - PLAYER_HEIGHT < frame.minY {
                    player.position.y = frame.minY + PLAYER_HEIGHT
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if birdFrozen {
            for touch in touches {
                let location = touch.location(in: self)
                let node : SKNode = self.atPoint(location)
                if node.name == "player" {
                    birdTouches = birdTouches + 1
                    if birdTouches == 3 {
                        birdTouches = 0
                        birdFrozen = false
                    }
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        for child in children {
            if child.frame.maxX < 0 {
                if !frame.intersects(child.frame) {
                    child.removeFromParent()
                }
            }
        }
        
        let activeEnemies = children.compactMap{ $0 as? EnemyNode }
        
        if activeEnemies.isEmpty {
            createWave()
        }
    }
    
    func createWave() {
        guard isPlayerAlive else { return }
        
        if waveNumber == waves.count {
            levelNumber += 1
            waveNumber = 0
        }
        
        let currentWave = waves[waveNumber]
        waveNumber += 1
        
        let maximumEnemyType = min(enemyTypes.count, levelNumber + 1)
        let bonusType = Int.random(in: 0..<bonusTypes.count)
        
        let enemyOffsetX: CGFloat = 60
        let enemyStartX = 600

        if currentWave.enemies.isEmpty {
            for (index, var position) in positions.shuffled().enumerated() {
                let enemyType = Int.random(in: 0..<maximumEnemyType)
                let type = enemyTypes[enemyType]
                if type.location == "air" {
                    if position < 0 {
                        position = position * -1
                    }
                } else {
                    position = -320
                }
                let enemy = EnemyNode(type: type, startPosition: CGPoint(x: enemyStartX, y: position), xOffset: enemyOffsetX * CGFloat(index * 3))
                addChild(enemy)
            }
        }
        
        if !currentWave.bonus.isEmpty {
            for bonus in currentWave.bonus {
                let type = bonusTypes[bonusType]
                let node = BonusNode(type: type, startPosition: CGPoint(x: 600, y: positions[bonus.position]), xOffset: 100 * bonus.xOffset)
                if node.appear(chanceToAppear: type.chanceToAppear) {
                    addChild(node)
                }
            }
        }
    }
    
    func gameOver () {
        isPlayerAlive = false
        if let delegate = self.gameDelegate {
            delegate.gameOver()
        }
        
        addChild(gameOverImg)
    }
    
    func displayYourRank (_ winner: Bool = false) {
        gameOverImg.removeFromParent()
        var nodeToDisplay = SKSpriteNode()
        if winner {
            nodeToDisplay = SKSpriteNode(imageNamed: "winner")
        } else {
            nodeToDisplay = SKSpriteNode(imageNamed: "looser")
        }
        addChild(nodeToDisplay)
    }
    
    func infligeBonus (type: String) {
        switch type {
            case BonusTypes.BALLOON.rawValue:
                balloonEffect()
            case BonusTypes.FLASHLIGHT.rawValue:
                flashlightEffect()
            case BonusTypes.STONE.rawValue:
                stoneEffect()
            case BonusTypes.ICE.rawValue:
                iceEffect()
            default:
                balloonEffect()
        }
    }
    
    func balloonEffect () {
        player.size = CGSize(width: 150, height: 150)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.player.size = CGSize(width: 100, height: 100)
            self.player.physicsBody = SKPhysicsBody(rectangleOf: self.player.size)
        }
    }
    
    func flashlightEffect () {
        let broken = SKSpriteNode(imageNamed: "broken")
        broken.size = CGSize(width: displaySize.width, height: displaySize.height)
        addChild(broken)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            broken.removeFromParent()
        }
    }
    
    func stoneEffect () {
        let broken = SKSpriteNode(imageNamed: "broken")
        broken.size = CGSize(width: displaySize.width, height: displaySize.height)
        addChild(broken)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            broken.removeFromParent()
        }
    }
    
    func iceEffect () {
        birdFrozen = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            if self.birdFrozen {
                self.birdFrozen = false
            }
        }
    }
}

extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        let sortedNodes = [nodeA, nodeB].sorted { $0.name ?? "" < $1.name ?? "" }
        let firstNode = sortedNodes[0]
        let secondNode = sortedNodes[1]
        
        if firstNode.name == "enemy" && secondNode.name == "player" {
            guard isPlayerAlive else { return }
            
            playerShield -= 1
            
            if playerShield == 0 {
                gameOver()
                secondNode.removeFromParent()
            }
            firstNode.removeFromParent()
        } else if firstNode.name == "bonus" && secondNode.name == "player" {
            if let bonus = firstNode as? BonusNode {
                if let delegate = self.gameDelegate {
                    delegate.catchBonus(type: bonus.type.name)
                }
            }
            firstNode.removeFromParent()
        }
    }
}
