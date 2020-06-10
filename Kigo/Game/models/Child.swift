//
//  Children.swift
//  Kigo-iPhone
//
//  Created by Florian on 11/05/2020.
//  Copyright © 2020 blandinf. All rights reserved.
//

import Foundation

struct Child: Codable {
    let id: String
    let accountId: String
    var firstname: String
    var gender: String
    var location: Int
    var gamesNotAllowed: [String]
    var activity: String
    var currentGame: String
    var currentSleep: String
    
    init?(id: String, data: [String: Any]) {
        
        self.id = id
        
        guard let accountId = data["accountId"] as? String,
            let firstname = data["firstname"] as? String,
            let gender = data["gender"] as? String,
            let location = data["location"] as? Int,
            let gamesNotAllowed = data["gamesNotAllowed"] as? [String],
            let activity = data["activity"] as? String,
            let currentGame = data["currentGame"] as? String,
            let currentSleep = data["currentSleep"] as? String
        else {
            return nil
        }
            
        self.accountId = accountId
        self.firstname = firstname
        self.gender = gender
        self.location = location
        self.gamesNotAllowed = gamesNotAllowed
        self.activity = activity
        self.currentGame = currentGame
        self.currentSleep = currentSleep
    }
}
