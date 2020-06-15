//
//  WaitingViewController.swift
//  Kigo
//
//  Created by Florian on 27/04/2020.
//  Copyright © 2020 blandinf. All rights reserved.
//

import UIKit
import AVFoundation

class WaitingViewController: UIViewController {
    var player: Player?
    var currentChild: Child?
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var waitingView: UIView!
    
    @IBOutlet weak var closeBtn: UIImageView!
    
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuView.backgroundColor = .clear
                       
        let closeBtnClick = UITapGestureRecognizer(target: self, action: #selector(WaitingViewController.backHome));
        closeBtn.addGestureRecognizer(closeBtnClick)
        closeBtn.isUserInteractionEnabled = true
        
//        var indicator = MaterialLoadingIndicator(frame: CGRect(x:waitingView.center.x/2, y:view.center.y/2 - 75, width: 40, height: 40))
//        self.waitingView.addSubview(indicator)
//        indicator.startAnimating()
        
        initializeChild()
    }
    
    @objc func backHome() {
        let homeViewController = storyBoard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        if !(self.navigationController!.viewControllers.contains(homeViewController)){
            self.navigationController?.pushViewController(homeViewController, animated: false)
        }
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
                   self.player = Player(name: child.firstname)
                   self.sendToServer(player: self.player!)
               }
           }
       }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GameViewController" {
            if let destination = segue.destination as? GameViewController {
                if let myPlayer = player,
                    let child = currentChild
                {
                    destination.currentPlayer = myPlayer
                    destination.currentChild = child
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
    
    override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(animated)
        
            SocketIOManager.sharedInstance.listen(event: "GameIsReady", callback: { (data, ack) in
                let gameViewController = self.storyBoard.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
                if let myPlayer = self.player,
                    let child = self.currentChild
                {
                    gameViewController.currentPlayer = myPlayer
                    gameViewController.currentChild = child
                }
                if !(self.navigationController!.viewControllers.contains(gameViewController)){
                    self.navigationController?.pushViewController(gameViewController, animated: false)
                }
            })
        
           captureSession = AVCaptureSession()
           captureSession.sessionPreset = .medium
           guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video) else {
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
           view.addSubview(menuView)
           view.addSubview(waitingView)           
           
           DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
               self.captureSession.startRunning()
               DispatchQueue.main.async {
                   self.videoPreviewLayer.frame = self.view.bounds
               }
           }
       }
}
