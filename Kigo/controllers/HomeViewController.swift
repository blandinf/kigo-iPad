//
//  ViewController.swift
//  Kigo
//
//  Created by Florian on 23/04/2020.
//  Copyright © 2020 blandinf. All rights reserved.
//

import UIKit
import AVFoundation

class HomeViewController: UIViewController {
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    @IBOutlet weak var menuView: UIView!
    
    @IBOutlet weak var drawButton: UIImageView!
    
    
    @IBOutlet weak var gameButton: UIImageView!
    @IBOutlet weak var gameView: UIView!
    
    var games = [APIGame]()
    var currentChild: Child?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        menuView.backgroundColor = .clear
        gameView.layer.cornerRadius = 20
        
        gameButton.image = UIImage(named: "gameBtn")
        drawButton.image = UIImage(named: "drawBtn")
        
        let gameBtnClick = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.gameButtonClicked));
        gameButton.addGestureRecognizer(gameBtnClick)
        gameButton.isUserInteractionEnabled = true
        
        let drawBtnClick = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.drawButtonClicked));
        drawButton.addGestureRecognizer(drawBtnClick)
        drawButton.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initializeGames()
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
            //        if let child = currentChild {
            //            print("child id \(child.id)")
            //            Firestore.firestore().collection("child").document(child.id)
            //            .addSnapshotListener { documentSnapshot, error in
            //                guard let snapshot = documentSnapshot else {
            //                    print("Error fetching snapshots: \(error!)")
            //                    return
            //                }
            //                print("snapshot \(snapshot)")
            //            }
            //        }
           }
       }
    }
    
    func initializeGames () {
       GameService.getGames { gameArray, error in
           if let err = error {
               print(err)
               return
           }
           self.games = gameArray
            print(self.games)
           self.myCollectionView.reloadData()
       }
    }
    
    @objc func gameButtonClicked() {
        if gameButton.image == UIImage(named: "closeBtn") {
            gameButton.image = UIImage(named: "gameBtn")
            gameView.isHidden = true
        } else {
            gameButton.image = UIImage(named: "closeBtn")
            gameView.isHidden = false
        }
    }
    
    @objc func drawButtonClicked() {
        if drawButton.image == UIImage(named: "closeBtn") {
            drawButton.image = UIImage(named: "drawBtn")
        } else {
            drawButton.image = UIImage(named: "closeBtn")
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
        view.addSubview(gameView)
        view.addSubview(menuView)
        
        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.view.bounds
            }
        }
    }
}

extension HomeViewController: UICollectionViewDelegate {
    
}

extension HomeViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return games.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameCollectionViewCell", for: indexPath) as! GameCollectionViewCell
        
        cell.gameImg.image = UIImage(named: games[indexPath.row].image)
        cell.gameLbl.text = games[indexPath.row].name
        
        cell.listenToImgClicked { () in
            if self.games[indexPath.row].name == "Les obstacles" {
                self.performSegue(withIdentifier: "OnBoardingViewController", sender: nil)
            }
        }

        return cell
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let w = collectionView.frame.width
        let h = collectionView.frame.height

        if let child = currentChild {
            if (child.gamesNotAllowed.contains(games[indexPath.row].name)) {
                return CGSize(width: 1, height: Int(h))
            } else {
                return CGSize(width: 150, height: Int(h))
            }
        }
        
        return CGSize(width: 150, height: Int(h))
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        return 0.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

        return 0.0
    }
}


