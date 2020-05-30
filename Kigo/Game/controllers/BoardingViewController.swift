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
    
    @IBOutlet weak var nextView: UIView!
    
    @IBOutlet weak var boardingImg: UIImageView!
    @IBOutlet weak var boardingView: UIView!
    @IBOutlet weak var boardingDescription: UILabel!
    @IBOutlet weak var boardingCurrentPage: UISegmentedControl!
    
    var currentGame: APIGame?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuView.backgroundColor = .clear
        nextView.backgroundColor = .clear
        
        closeBtn.image = UIImage(named: "closeBtn")
        
        let closeBtnClick = UITapGestureRecognizer(target: self, action: #selector(BoardingViewController.closeButtonClicked));
        closeBtn.addGestureRecognizer(closeBtnClick)
        closeBtn.isUserInteractionEnabled = true
        
        if let game = currentGame {
            boardingDescription.text = game.boardingInstructions[boardingCurrentPage.selectedSegmentIndex]
            boardingImg.image = UIImage(named: game.boardingImages[boardingCurrentPage.selectedSegmentIndex])
        }
    }
    
    @objc func closeButtonClicked() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func currentPageChanges(_ sender: UISegmentedControl) {
        if let game = currentGame {
            boardingDescription.text = game.boardingInstructions[sender.selectedSegmentIndex]
            boardingImg.image = UIImage(named: game.boardingImages[sender.selectedSegmentIndex])
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
        view.addSubview(nextView)
        
        
        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.view.bounds
            }
        }
    }
}
