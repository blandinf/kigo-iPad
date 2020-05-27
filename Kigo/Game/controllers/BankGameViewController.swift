//
//  BankGameViewController.swift
//  Kigo
//
//  Created by Florian on 27/05/2020.
//  Copyright © 2020 blandinf. All rights reserved.
//

import UIKit

class BankGameViewController: UIViewController {
    @IBOutlet weak var bankView: UIView!
    @IBOutlet weak var myCollectionView: UICollectionView!
    var games = [APIGame]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initializeGames()
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "OnBoardingViewController" {
//            if let destination = segue.destination as? OnBoardingViewController {
//                if let myPlayer = player {
//                    destination.currentPlayer = myPlayer
//                }
//            }
//        }
//    }
    
    
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
}


extension BankGameViewController: UICollectionViewDelegate {
    
}

extension BankGameViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return games.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameCollectionViewCell", for: indexPath) as! GameCollectionViewCell
        
        print(games[indexPath.row].name)
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

extension BankGameViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let w = collectionView.frame.width
        let h = collectionView.frame.height

        let count = games.count
        return CGSize(width: 200, height: Int(h))
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        return 0.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

        return 0.0
    }
}
