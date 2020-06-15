//
//  EnemyNode.swift
//  Kigo
//
//  Created by Florian on 17/04/2020.
//  Copyright © 2020 blandinf. All rights reserved.
//

import SpriteKit

class EnemyNode: SKSpriteNode {
    var type: EnemyType
    
    init(type: EnemyType, startPosition: CGPoint, xOffset: CGFloat, moveSpeed: CGFloat) {
        self.type = type
        
        super.init(texture: SKTexture(), color: .white, size: CGSize())
                
        texture = SKTexture(imageNamed: type.name)
        size = getSize(texture: texture!)
        zRotation = 0.20
        color = .red
        
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.categoryBitMask = CollisionType.enemy.rawValue
        physicsBody?.collisionBitMask = CollisionType.enemy.rawValue
        physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue
        name = "enemy"
        position = CGPoint(x: startPosition.x + xOffset, y: startPosition.y)
        
        configureMovement(moveSpeed: moveSpeed)
    }
//
//    func fillWithRandomTexture () -> SKTexture {
//        let random = Int.random(in: 1...type.variety)
//        var finalType: String = ""
//
//        if type.name != "plane" {
//            finalType = type.name + "\(random)"
//        } else {
//            finalType = type.name
//        }
//
//        return SKTexture(imageNamed: finalType)
//    }
    
    func getSize (texture: SKTexture) -> CGSize {
        let randomWidth = Int.random(in: 100...220)
        let size = CGSize(width: randomWidth, height: 460)
    
        return size
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NO")
    }
    
    func configureMovement(moveSpeed: CGFloat) {
        let path = UIBezierPath()
        path.move(to: .zero)
        
        path.addLine(to: CGPoint(x: -10000, y: 0))
        
        let movement = SKAction.follow(path.cgPath, asOffset: true, orientToPath: false, speed: moveSpeed)
        let sequence = SKAction.sequence([movement, .removeFromParent()])
        run(sequence)
    }
}
