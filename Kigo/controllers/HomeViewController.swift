//
//  ViewController.swift
//  Kigo
//
//  Created by Florian on 23/04/2020.
//  Copyright © 2020 blandinf. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Firebase
import MapKit

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
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var remainingTimeLbl: UILabel!
    @IBOutlet weak var carImage: UIImageView!
    
    var games = [APIGame]()
    var currentChild: Child?
    var currentGame: APIGame?
    var currentActivity: String = ""
    var gameLaunched = false
    var playerItem:AVPlayerItem?
    var player:AVPlayer?
    var playerLayer: AVPlayerLayer?
    var animationLaunched = false
    var from = CLLocationCoordinate2D()
    var timer:Timer?
    var currentDestination = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        render()
        listen()
        prepareAnimation()
        bindCurrentLocation()
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
    
    func bindCurrentLocation () {
        Utils.getCoordinateFrom(address: "Annecy, France") { coordinate, error in
            guard let coordinate = coordinate, error == nil else { return }
            DispatchQueue.main.async {
                self.from = coordinate
            }
        }
    }
    
    func render () {
        menuView.backgroundColor = .clear
        gameView.layer.cornerRadius = 20
        
        drawView.backgroundColor = .clear
        drawView.pinEdges(to: view)
        
        kitView.layer.cornerRadius = 6
        kitView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        
        gameButton.image = UIImage(named: "jeu")
        drawButton.image = UIImage(named: "dessin")
        
        progressView.transform = progressView.transform.scaledBy(x: 1, y: 7)
    }
    
    func prepareAnimation () {
        guard let path = Bundle.main.path(forResource: "Ambiance-nuit", ofType:"mp4") else {
           debugPrint("video.m4v not found")
           return
        }
        playerItem = AVPlayerItem(url: URL(fileURLWithPath: path))
        player = AVPlayer(playerItem: playerItem!)
        playerLayer = AVPlayerLayer(player: player!)
        playerLayer!.frame = view.layer.bounds
    }
    
    func showRemainingTime (destination: String) {
        if destination.isEmpty {
            carImage.isHidden = true
            remainingTimeLbl.isHidden = true
            progressView.isHidden = true
        } else {
            carImage.isHidden = false
            remainingTimeLbl.isHidden = false
            progressView.isHidden = false
        }
    }
    
    func updateTime (destination: String) {
        var to = CLLocationCoordinate2D()
        Utils.getCoordinateFrom(address: destination) { coordinate, error in
            guard let coordinate = coordinate, error == nil else { return }
            DispatchQueue.main.async {
                to = coordinate
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if self.from.latitude != 0 && self.from.longitude != 0 && to.longitude != 0 && to.latitude != 0 {
                let distanceInMeters = Utils.distance(from: self.from, to: to)
                let distancesInKms = Int(Int(distanceInMeters) / 1000)
                let estimation = Double(Double(distancesInKms) / 70.0)
                let hours = Int(estimation)
                var minutes = Int((estimation - Double(hours)) * 100)
                minutes = minutes * 60 / 100
                
                self.remainingTimeLbl.text = "ARRIVÉE DANS"
                
                if hours > 0 {
                    self.remainingTimeLbl.text! += " \(hours)H "
                }
                
                if minutes > 0 {
                    self.remainingTimeLbl.text! += "\(minutes)MIN"
                }
                
                self.launchDestinationCountdown(hours: hours, minutes: minutes)
            } else {
                self.showRemainingTime(destination: "")
            }
        }
    }
    
    func launchDestinationCountdown (hours: Int, minutes: Int) {
        self.progressView.progress = 0.0
        let hoursInMinutes = hours * 60
        var totalMinutes = hoursInMinutes + minutes
        let coeff = CGFloat(100.0/Float(totalMinutes))
        let offset = 1.0 / Double(totalMinutes)
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
            totalMinutes -= 1
            self.progressView.progress += Float(offset)
            self.carImage.center.x += CGFloat(Float(offset)) * 100 + coeff
            let result = Utils.convertMinutesToHoursAndMinutes(totalMinutes: totalMinutes)
            if (result.hours > 0) {
                self.remainingTimeLbl.text = "ARRIVÉE DANS \(result.hours)H \(result.minutes)MIN"
            } else {
                self.remainingTimeLbl.text = "ARRIVÉE DANS \(result.minutes)MIN"
            }
            
            if totalMinutes <= 0 || self.progressView.progress >= 1.0 {
                self.remainingTimeLbl.text = "VOUS ÊTES ARRIVÉS!"
                timer.invalidate()
            }
        })
    }

    func listenChildChanges (child: Child) {
        Firestore.firestore().collection("child").document(child.id)
        .addSnapshotListener { documentSnapshot, error in
            guard let snapshot = documentSnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            if let gamesNotAllowed = snapshot.data()!["gamesNotAllowed"] as? [String]{
                self.currentChild?.gamesNotAllowed = gamesNotAllowed
                self.myCollectionView.reloadData()
            }
            if let activity = snapshot.data()!["activity"] as? String {
                if activity == "sleeping" {
                    self.launchAnimationInLoop()
                    self.animationLaunched = true
                } else {
                    self.stopAnimation()
                }
            }
            if let destination = snapshot.data()!["destination"] as? String {
                self.showRemainingTime(destination: destination)
                if !destination.isEmpty && destination != self.currentDestination {
                    self.currentDestination = destination
                    if let t = self.timer {
                        t.invalidate()
                    }
                    self.updateTime(destination: destination)
                }
            }
        }
    }
    
    func launchAnimationInLoop() {
        self.view.layer.addSublayer(playerLayer!)
        player?.play()
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: nil)
        { notification in
            self.player?.seek(to: .zero)
            self.player?.play()
        }
    }
    
    func stopAnimation() {
        if animationLaunched {
            self.player?.pause()
            self.playerLayer?.removeFromSuperlayer()
            self.animationLaunched = false
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
                    self.listenChildChanges(child: child)
                    self.showRemainingTime(destination: child.destination)
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
           self.myCollectionView.reloadData()
       }
    }
    
    @objc func gameButtonClicked() {
        if gameButton.image == UIImage(named: "closeBtn2") {
            if let child = currentChild {
                ChildrenService.updateActivity(id: child.id, activity: "")
                ChildrenService.updateCurrentGame(id: child.id, currentGame: "")
            }
            gameButton.image = UIImage(named: "jeu")
            gameView.isHidden = true
        } else {
            if let child = currentChild {
                ChildrenService.updateActivity(id: child.id, activity: "gaming")
            }
            gameButton.image = UIImage(named: "closeBtn2")
            gameView.isHidden = false
        }
    }
    
    @IBAction func deleteDraw(_ sender: Any) {
        if drawView.isHidden == false {
            drawView.clear()
        }
    }
    
    @objc func drawButtonClicked() {
        if drawButton.image == UIImage(named: "closeBtn2") {
            if (gameLaunched == false) {
                self.currentActivity = ""
            }
            drawButton.image = UIImage(named: "dessin")
            drawView.isHidden = true
            kitView.isHidden = true
            gameButton.center.x = gameButton.center.x + 50
        } else {
            self.currentActivity = "drawing"
            drawButton.image = UIImage(named: "closeBtn2")
            drawView.isHidden = false
            kitView.isHidden = false
            gameButton.center.x = gameButton.center.x - 50
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

