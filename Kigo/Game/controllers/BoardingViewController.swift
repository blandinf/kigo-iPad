//
//  BoardingViewController.swift
//  Kigo
//
//  Created by Florian on 29/05/2020.
//  Copyright © 2020 blandinf. All rights reserved.
//

import UIKit
import AVFoundation

class BoardingViewController: UIViewController {
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var closeBtn: UIImageView!
        
    @IBOutlet weak var boardingDescription: UILabel!
    @IBOutlet weak var boardingImg: UIImageView!
    @IBOutlet weak var boardingView: UIView!
    
    @IBOutlet weak var previousBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var navigationView: UIView!
    
    var currentPage = 0
    
    var currentGame: APIGame?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuView.backgroundColor = .clear
        boardingView.layer.cornerRadius = 15
        boardingImg.layer.cornerRadius = 10
                
        let closeBtnClick = UITapGestureRecognizer(target: self, action: #selector(BoardingViewController.closeButtonClicked));
        closeBtn.addGestureRecognizer(closeBtnClick)
        closeBtn.isUserInteractionEnabled = true
        
        navigationView.layer.cornerRadius = 15
        navigationView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        if let game = currentGame {
            boardingDescription.text = game.boardingInstructions[currentPage]
            boardingImg.image = UIImage(named: game.boardingImages[currentPage])
        }
    }
    
    @objc func closeButtonClicked() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func previous(_ sender: Any) {
        if currentPage > 0 {
            currentPage = currentPage - 1
            if let game = currentGame {
                boardingDescription.text = game.boardingInstructions[currentPage]
                boardingImg.image = UIImage(named: game.boardingImages[currentPage])
            }
        }
    }
    
    @IBAction func next(_ sender: Any) {
        if let game = currentGame {
            if currentPage < game.boardingInstructions.count - 1 {
                currentPage = currentPage + 1
                boardingDescription.text = game.boardingInstructions[currentPage]
                boardingImg.image = UIImage(named: game.boardingImages[currentPage])
            } else if currentPage == game.boardingInstructions.count - 1 {
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let waitingViewController = storyBoard.instantiateViewController(withIdentifier: "WaitingViewController") as! WaitingViewController
                self.navigationController?.pushViewController(waitingViewController, animated: true)
            }
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
        view.addSubview(menuView)
        view.addSubview(boardingView)        
        
        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.view.bounds
            }
        }
    }
}
