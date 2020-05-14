//
//  GameDelegate.swift
//  Kigo
//
//  Created by Florian on 03/05/2020.
//  Copyright © 2020 blandinf. All rights reserved.
//

import Foundation

@objc protocol GameDelegate {
    func gameOver()
    func catchBonus(type: String)
}
