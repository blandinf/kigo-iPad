//
//  BonusNode.swift
//  Kigo
//
//  Created by Florian on 17/04/2020.
//  Copyright © 2020 blandinf. All rights reserved.
//

import SpriteKit

class BonusNode: SKSpriteNode {
    var type: BonusType
    
    init(type: BonusType, startPosition: CGPoint, xOffset: CGFloat) {
        self.type = type

        super.init(texture: SKTexture(), color: .white, size: CGSize())
                       
        texture = fillWithRandomTexture()
        size = CGSize(width: type.width, height: type.height)
                
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.categoryBitMask = CollisionType.bonus.rawValue
        physicsBody?.collisionBitMask = CollisionType.bonus.rawValue
        physicsBody?.contactTestBitMask = CollisionType.bonus.rawValue
        name = "bonus"
        position = CGPoint(x: startPosition.x + xOffset, y: startPosition.y)
        
        configureMovement()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NO")
    }
    
    func fillWithRandomTexture () -> SKTexture {
        let random = Int.random(in: 1...type.variety)
        var finalType: String = ""
        
        if type.name == "stone" {
            finalType = type.name + "\(random)"
        } else {
            finalType = type.name
        }
        
        return SKTexture(imageNamed: finalType)
    }
    
    func configureMovement() {
       let path = UIBezierPath()
       path.move(to: .zero)
       
        path.addCurve(to: CGPoint(x: -3500, y: 0), controlPoint1: CGPoint(x: 0, y: -position.y * 4), controlPoint2: CGPoint(x: -1000, y: -position.y))
       
       let movement = SKAction.follow(path.cgPath, asOffset: true, orientToPath: false, speed: type.speed)
       let sequence = SKAction.sequence([movement, .removeFromParent()])
       run(sequence)
   }
    
    func appear(chanceToAppear: CGFloat) -> Bool {
        var randomNumber = CGFloat.random(in: 0.0...1.0)
        
        if randomNumber > chanceToAppear {
            return true
        }
        return false
    }
}
