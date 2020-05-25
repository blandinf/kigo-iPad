//
//  WaitingViewController.swift
//  Kigo
//
//  Created by Florian on 27/04/2020.
//  Copyright © 2020 blandinf. All rights reserved.
//

import UIKit

class WaitingViewController: UIViewController {
    @IBOutlet weak var usernameLbl: UILabel!
    var player: Player?
    var currentChild: Child?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeChild()
    }
    
    func initializeChild () {
        if let id = UserDefaults.standard.string(forKey: "connectedChildId") {
            ChildrenService.getChild(id: id) { child, error in
                if let err = error {
                    print(err)
                    return
                }
                self.currentChild = child
                if let child = self.currentChild {
                    self.usernameLbl.text = child.firstname
                    self.player = Player(name: child.firstname)
                    self.sendToServer(player: self.player!)
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        SocketIOManager.sharedInstance.listen(event: "GameIsReady", callback: { (data, ack) in
            self.performSegue(withIdentifier: "GameViewController", sender: nil)
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GameViewController" {
            if let destination = segue.destination as? GameViewController {
                if let myPlayer = player {
                    destination.currentPlayer = myPlayer
                }
            }
        }
    }
    
    func sendToServer(player: Player) {
        if let json = Player.fromObjectToJson(currentPlayer: player) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
               print("send playerConnect")
               SocketIOManager.sharedInstance.emit(event: "playerConnect", message: ["player": json])
            }
        }
    }
}
