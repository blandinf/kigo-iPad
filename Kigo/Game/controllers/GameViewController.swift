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

class GameViewController: UIViewController {
    @IBOutlet weak var skView: SKView!
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var currentPlayer: Player? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let scene = GameScene(fileNamed: "GameScene") {
            scene.scaleMode = .aspectFill
            scene.backgroundColor = .clear
            scene.gameDelegate = self
            skView.presentScene(scene)
            infligeBonus(scene: scene)
            whoIsTheWinner(scene: scene)
        }
        
        skView.backgroundColor = .clear
        skView.pinEdges(to: view)
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
            if let player = self.currentPlayer {
                if let result = data[0] as? String {
                    if player.id == result {
                         scene.displayYourRank(true)
                    } else {
                         scene.displayYourRank()
                    }
                }
            }
        })
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
        
        
        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.view.bounds
            }
        }
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
        let jsonEncoder = JSONEncoder()
        do {
            if let player = currentPlayer {
                let jsonData = try jsonEncoder.encode(player)
                print(jsonData)
                if let json = String(data: jsonData, encoding: .utf8) {
                    SocketIOManager.sharedInstance.emit(event: "playerIsDead", message: ["player": json])
                }
            }
        } catch {
            print("error")
        }
    }
    
    func catchBonus(type: String) {
        let jsonEncoder = JSONEncoder()
        do {
           if let player = currentPlayer {
               let jsonData = try jsonEncoder.encode(player)
               print(jsonData)
               if let json = String(data: jsonData, encoding: .utf8) {
                    SocketIOManager.sharedInstance.emit(event: "catchBonus", message: ["player": json, "bonus": type])
               }
           }
        } catch {
           print("error")
        }
    }
}
