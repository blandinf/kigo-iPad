//
//  WhoViewController.swift
//  Kigo
//
//  Created by Florian on 14/05/2020.
//  Copyright © 2020 blandinf. All rights reserved.
//

import UIKit
import AVFoundation

class WhoViewController: UIViewController {
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    var childrens = [Child]()
    @IBOutlet weak var childSelected: UISegmentedControl!
    
    @IBOutlet weak var whoView: UIView!
    @IBOutlet weak var navigationView: UIView!
    
    override func viewDidLoad() {
        navigationView.backgroundColor = .clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initializeChildren()
    }
    
    @IBAction func next(_ sender: Any) {
        UserDefaults.standard.set(childrens[childSelected.selectedSegmentIndex].id, forKey: "connectedChildId")
    }
    
    func initializeChildren () {
       ChildrenService.getChildren { childrenArray, error in
           if let err = error {
               print(err)
               return
           }
           self.childrens = childrenArray
           for (index, child) in self.childrens.enumerated() {
              self.childSelected.setTitle(child.firstname, forSegmentAt: index)
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
        view.addSubview(navigationView)
        view.addSubview(whoView)
        
        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.view.bounds
            }
        }
    }
}
