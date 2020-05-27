//
//  GameCollectionViewCell.swift
//  Kigo
//
//  Created by Florian on 27/05/2020.
//  Copyright © 2020 blandinf. All rights reserved.
//

import UIKit

class GameCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var gameLbl: UILabel!
    @IBOutlet weak var gameImg: UIImageView!
    var localCollback: (()->())?
    
    override func awakeFromNib() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(GameCollectionViewCell.tappedMe));
        gameImg.addGestureRecognizer(tap)
        gameImg.isUserInteractionEnabled = true
    }

    func listenToImgClicked(callback: @escaping ()->()) {
        self.localCollback = callback
    }
    
    @objc func tappedMe() {
       if let callback = localCollback {
            callback()
        }
    }
}
