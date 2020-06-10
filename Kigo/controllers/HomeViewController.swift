//
//  ViewController.swift
//  Kigo
//
//  Created by Florian on 23/04/2020.
//  Copyright © 2020 blandinf. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

class HomeViewController: UIViewController {
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var drawView: SwiftSignatureView!
    @IBOutlet weak var kitView: UIView!
    @IBOutlet weak var gameView: UIView!
    
    @IBOutlet weak var drawButton: UIImageView!
    @IBOutlet weak var deleteDrawBtn: UIImageView!
    @IBOutlet weak var gameButton: UIImageView!
    
    var games = [APIGame]()
    var currentChild: Child?
    var currentGame: APIGame?
    var currentActivity: String = ""
    var gameLaunched = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        render()
        listen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initializeGames()
        initializeChild()
        self.gameLaunched = false
        if let child = currentChild {
            ChildrenService.updateActivity(id: child.id, activity: "")
            ChildrenService.updateCurrentGame(id: child.id, currentGame: "")
        }
    }
    
    func listen () {
        let gameBtnClick = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.gameButtonClicked));
        gameButton.addGestureRecognizer(gameBtnClick)
        gameButton.isUserInteractionEnabled = true
        
        let drawBtnClick = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.drawButtonClicked));
        drawButton.addGestureRecognizer(drawBtnClick)
        drawButton.isUserInteractionEnabled = true
    }
    
    func render () {
        menuView.backgroundColor = .clear
        gameView.layer.cornerRadius = 20
        
        drawView.backgroundColor = .clear
        drawView.pinEdges(to: view)
        
        kitView.layer.cornerRadius = 30
        
        gameButton.image = UIImage(named: "gameBtn")
        drawButton.image = UIImage(named: "drawBtn")
        
        let gameBtnClick = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.gameButtonClicked));
        gameButton.addGestureRecognizer(gameBtnClick)
        gameButton.isUserInteractionEnabled = true
        
        let drawBtnClick = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.drawButtonClicked));
        drawButton.addGestureRecognizer(drawBtnClick)
        drawButton.isUserInteractionEnabled = true
        
        self.navigationController?.isNavigationBarHidden = true
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
               if let child = self.currentChild {
                    self.listenChildChanges(child: child)
               }
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
            print("games \(self.games)")
           self.myCollectionView.reloadData()
       }
    }
    
    @objc func gameButtonClicked() {
        if gameButton.image == UIImage(named: "closeBtn") {
            if let child = currentChild {
                ChildrenService.updateActivity(id: child.id, activity: "")
                ChildrenService.updateCurrentGame(id: child.id, currentGame: "")
            }
            gameButton.image = UIImage(named: "gameBtn")
            gameView.isHidden = true
        } else {
            if let child = currentChild {
                ChildrenService.updateActivity(id: child.id, activity: "gaming")
            }
            gameButton.image = UIImage(named: "closeBtn")
            gameView.isHidden = false
        }
    }
    
    @IBAction func deleteDraw(_ sender: Any) {
        if drawView.isHidden == false {
            drawView.clear()
        }
    }
    
    @objc func drawButtonClicked() {
        if drawButton.image == UIImage(named: "closeBtn") {
            if (gameLaunched == false) {
                self.currentActivity = ""
            }
            drawButton.image = UIImage(named: "drawBtn")
            drawView.isHidden = true
            kitView.isHidden = true
            gameButton.center.x = gameButton.center.x - 50
        } else {
            self.currentActivity = "drawing"
            drawButton.image = UIImage(named: "closeBtn")
            drawView.isHidden = false
            kitView.isHidden = false
            gameButton.center.x = gameButton.center.x + 50
        }
        if let child = currentChild {
            ChildrenService.updateActivity(id: child.id, activity: currentActivity)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OnBoardingViewController" {
            if let destination = segue.destination as? BoardingViewController {
                if let myCurrentGame = currentGame {
                    destination.currentGame = myCurrentGame
                }
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
        view.addSubview(gameView)
        view.addSubview(drawView)
        view.addSubview(kitView)
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
            self.currentGame = self.games[indexPath.row]
            
            if self.games[indexPath.row].name == "Les obstacles" {
                self.performSegue(withIdentifier: "OnBoardingViewController", sender: nil)
                self.gameLaunched = true
                self.gameButtonClicked()
                if let child = self.currentChild {
                    ChildrenService.updateActivity(id: child.id, activity: "gaming")
                    ChildrenService.updateCurrentGame(id: child.id, currentGame: self.games[indexPath.row].name)
                }
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


