//
//  GameViewController.swift
//  SpaceGame
//
//  Created by Florian on 17/04/2020.
//  Copyright © 2020 blandinf. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation
import Firebase

class GameViewController: UIViewController {
    @IBOutlet weak var skView: SKView!
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var currentPlayer: Player? = nil
    var currentChild: Child? = nil
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    var gameBlocked = false
    var viewAlreadyPush = false
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var closeBtn: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuView.backgroundColor = .clear
        let closeBtnClick = UITapGestureRecognizer(target: self, action: #selector(GameViewController.backHome));
        closeBtn.addGestureRecognizer(closeBtnClick)
        closeBtn.isUserInteractionEnabled = true
        
        if let scene = GameScene(fileNamed: "GameScene") {
            scene.scaleMode = .aspectFill
            scene.backgroundColor = .clear
            scene.gameDelegate = self
            if let child = currentChild {
                scene.currentChild = child
            }
            skView.presentScene(scene)
            infligeBonus(scene: scene)
            whoIsTheWinner(scene: scene)
            blockGameListener(scene: scene)
        }
        
        skView.backgroundColor = .clear
        skView.pinEdges(to: view)
    }
    
    @objc func backHome() {
        let homeViewController = storyBoard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        if !(self.navigationController!.viewControllers.contains(homeViewController)) {
            self.navigationController?.pushViewController(homeViewController, animated: false)
        }
    }
    
    func infligeBonus(scene: GameScene) {
        SocketIOManager.sharedInstance.listen(event: "infligeBonus", callback: { (data, ack) in
            if let dataAsString = data[0] as? String {
                if let jsonData = dataAsString.data(using: .utf8)
                {
                    let decoder = JSONDecoder()
                    do {
                        let bonus = try decoder.decode(Bonus.self, from: jsonData)
                        if let player = self.currentPlayer {
                            if bonus.playerIdToInflige != player.id {
                                scene.infligeBonus(type: bonus.type)
                            }
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        })
    }
    
    func whoIsTheWinner(scene: GameScene) {
        SocketIOManager.sharedInstance.listen(event: "winnerIs", callback: { (data, ack) in
            print("winnerIs called")
            if let player = self.currentPlayer,
                let child = self.currentChild
            {
                if let result = data[0] as? String {
                    if self.gameBlocked == false && self.viewAlreadyPush == false {
                        self.viewAlreadyPush = true
                        let rankViewController = self.storyBoard.instantiateViewController(withIdentifier: "RankViewController") as! RankViewController
                        rankViewController.winnerId = result
                        rankViewController.currentPlayer = player
                        rankViewController.currentChild = child
                        if !(self.navigationController!.viewControllers.contains(rankViewController)){
                            self.navigationController?.pushViewController(rankViewController, animated: false)
                        }
                    }
                }
            }
        })
    }
    
    func blockGameListener(scene: GameScene) {
        if let child = currentChild {
            Firestore.firestore().collection("child").document(child.id)
            .addSnapshotListener { documentSnapshot, error in
                guard let snapshot = documentSnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                if let gamesNotAllowed = snapshot.data()!["gamesNotAllowed"] as? [String] {
                    print(gamesNotAllowed)
                    self.currentChild?.gamesNotAllowed = gamesNotAllowed
                    if (gamesNotAllowed.contains("Les obstacles")) {
                        self.gameBlocked = true
                        let homeViewController = self.storyBoard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                        if !(self.navigationController!.viewControllers.contains(homeViewController)){
                            self.navigationController?.pushViewController(homeViewController, animated: false)
                        }
                    }
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
            else {
                print("Unable to access back camera!")
                return
        }
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            stillImageOutput = AVCapturePhotoOutput()
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupLivePreview()
            }
        }
        catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
    }
    
    func setupLivePreview() {
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        videoPreviewLayer.videoGravity = .resize
        videoPreviewLayer.connection?.videoOrientation = .landscapeRight
        view.layer.addSublayer(videoPreviewLayer)
        view.addSubview(skView)
        view.addSubview(menuView)
        
        
        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.view.bounds
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension GameViewController: GameDelegate {
    
    func gameOver() {
        print("playerIsDead")
        if let json = Player.fromObjectToJson(currentPlayer: currentPlayer) {
            SocketIOManager.sharedInstance.emit(event: "playerIsDead", message: ["player": json])
        }
    }
    
    func catchBonus(type: String) {
        if let json = Player.fromObjectToJson(currentPlayer: currentPlayer) {
            SocketIOManager.sharedInstance.emit(event: "catchBonus", message: ["player": json, "bonus": type])
        }
    }
}
