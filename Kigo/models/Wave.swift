//
//  Waves.swift
//  Kigo
//
//  Created by Florian on 17/04/2020.
//  Copyright © 2020 blandinf. All rights reserved.
//

import SpriteKit

struct Wave: Codable {
    struct WaveItem: Codable {
        let position: Int
        let xOffset: CGFloat
    }
    let name: String
    let enemies: [WaveItem]
    let bonus: [WaveItem]
}
