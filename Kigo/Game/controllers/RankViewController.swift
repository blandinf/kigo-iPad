//
//  RankViewController.swift
//  Kigo
//
//  Created by Florian on 24/05/2020.
//  Copyright © 2020 blandinf. All rights reserved.
//

import UIKit
import AVFoundation

class RankViewController: UIViewController {
    @IBOutlet weak var winnerLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    var winnerId: String? = nil
    var currentPlayer: Player? = nil
    var currentChild: Child? = nil
    @IBOutlet weak var rankView: UIView!
    @IBOutlet weak var navigationView: UIView!
    
    @IBOutlet weak var medalImg: UIImageView!
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rankView.layer.cornerRadius = 15
        navigationView.layer.cornerRadius = 15
        navigationView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        if let player = currentPlayer,
            let child = currentChild
        {
            if winnerId == player.id {
                winnerLbl.text = "BRAVO \(player.name.uppercased()) !"
                if child.gender == "F" {
                    descriptionLbl.text = "TU AS ÉTÉ LA MEILLEURE !"
                } else {
                    descriptionLbl.text = "TU AS ÉTÉ LE MEILLEUR !"
                }
            } else {
                winnerLbl.text = "DOMMAGE \(player.name.uppercased()), TU AS PERDU !"
                descriptionLbl.text = "RETENTE TA CHANCE !"
                medalImg.image = UIImage(named: "bronze-medal")
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
        if let json = Player.fromObjectToJson(currentPlayer: currentPlayer) {
            SocketIOManager.sharedInstance.emit(event: "playerDisconnect", message: ["player": json])
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let waitingViewController = storyBoard.instantiateViewController(withIdentifier: "WaitingViewController") as! WaitingViewController
            waitingViewController.player = currentPlayer
            self.navigationController?.pushViewController(waitingViewController, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        view.addSubview(rankView)
        
        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.view.bounds
            }
        }
    }
    
}
