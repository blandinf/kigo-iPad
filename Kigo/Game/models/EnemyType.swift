//
//  EnemyType.swift
//  Kigo
//
//  Created by Florian on 17/04/2020.
//  Copyright © 2020 blandinf. All rights reserved.
//

import SpriteKit

struct EnemyType: Codable {
    let name: String
    let speed: CGFloat
    let width: Int
    let height: Int
    let variety: Int
    let location: String
}
