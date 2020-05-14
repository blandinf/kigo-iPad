//
//  Player.swift
//  Kigo
//
//  Created by Florian on 27/04/2020.
//  Copyright © 2020 blandinf. All rights reserved.
//

import Foundation

struct Player: Codable {
    let id: String
    let name: String
    
    public init(name: String) {
        self.id = NSUUID().uuidString
        self.name = name
    }
    
    static func fromObjectToJson(player: Player) -> String? {
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(player)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            return nil
        }
    }
    
    static func fromJsonToObject(player: String) -> Player? {
        let jsonDecoder = JSONDecoder()
        do {
            if let jsonData = player.data(using: .utf8) {
                let player = try jsonDecoder.decode(Player.self, from: jsonData)
                return player
            }
            return nil
        } catch {
            return nil
        }
    }
}
