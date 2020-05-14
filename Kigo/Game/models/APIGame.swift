//
//  Game.swift
//  Kigo-iPhone
//
//  Created by Florian on 14/05/2020.
//  Copyright © 2020 blandinf. All rights reserved.
//

import Foundation

struct APIGame: Codable {
    let id: String
    let name: String
    let minAge: Int
    let minPlayers: Int
    let maxPlayers: Int
    let image: String
    
    init?(id: String, data: [String: Any]) {
        
        self.id = id
        
        guard let name = data["name"] as? String,
            let minAge = data["minAge"] as? Int,
            let minPlayers = data["minPlayers"] as? Int,
            let maxPlayers = data["maxPlayers"] as? Int,
            let image = data["image"] as? String
        else {
            return nil
        }
            
        self.name = name
        self.minAge = minAge
        self.minPlayers = minPlayers
        self.maxPlayers = maxPlayers
        self.image = image
    }
}
