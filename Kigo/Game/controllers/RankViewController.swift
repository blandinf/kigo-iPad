//
//  RankViewController.swift
//  Kigo
//
//  Created by Florian on 24/05/2020.
//  Copyright © 2020 blandinf. All rights reserved.
//

import UIKit

class RankViewController: UIViewController {
    @IBOutlet weak var winnerLbl: UILabel!
    var winnerId: String? = nil
    var currentPlayer: Player? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let player = currentPlayer {
            if winnerId == player.id {
                winnerLbl.text = "\(player.name) YOU WON"
            } else {
                winnerLbl.text = "\(player.name) YOU LOOSE"
            }
        }
    }
    
    @IBAction func backToHome(_ sender: Any) {
        if let json = Player.fromObjectToJson(currentPlayer: currentPlayer) {
            SocketIOManager.sharedInstance.emit(event: "playerDisconnect", message: ["player": json])
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let homeViewController = storyBoard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            self.navigationController?.pushViewController(homeViewController, animated: true)
        }
    }
    
    @IBAction func restart(_ sender: Any) {
        
    }
    
}
