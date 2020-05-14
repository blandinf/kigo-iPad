//
//  Bonus.swift
//  Kigo
//
//  Created by Florian on 07/05/2020.
//  Copyright © 2020 blandinf. All rights reserved.
//

import Foundation

struct Bonus: Codable {
    let playerIdToInflige: String
    let type: String
    
    public init(playerIdToInflige: String, type: String) {
        self.playerIdToInflige = playerIdToInflige
        self.type = type
    }
}
