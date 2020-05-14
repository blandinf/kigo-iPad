//
//  OnBoardingViewController.swift
//  Kigo
//
//  Created by Florian on 09/05/2020.
//  Copyright © 2020 blandinf. All rights reserved.
//

import UIKit

class OnBoardingViewController: UIViewController {
    @IBOutlet weak var myScrollView: UIScrollView!
    var slides:[Slide] = [];
    @IBOutlet weak var pageControl: UIPageControl!
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myScrollView.delegate = self
        
        slides = createSlides()
        setupSlideScrollView(slides: slides)
        
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        view.bringSubviewToFront(pageControl)
    }
    
    func createSlides() -> [Slide] {

        let slide1:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide1.myImageView.image = UIImage(named: "bird-step1")
        slide1.titleLbl.text = "Règles du jeu"
        slide1.descriptionLbl.text = "Garde ton doigt appuyé sur l'écran et fais le monter ou descendre pour diriger l'oiseau."
        
        let slide2:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide2.myImageView.image = UIImage(named: "bird-step2")
        slide2.titleLbl.text = "Règles du jeu"
        slide2.descriptionLbl.text = "Evite les obstacles qui arrivent à ta droite."
        
        let slide3:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide3.myImageView.image = UIImage(named: "bird-step3")
        slide3.titleLbl.text = "Règles du jeu"
        slide3.descriptionLbl.text = "Récupère les bonus pour pénaliser ton adversaire !"
        
        return [slide1, slide2, slide3]
    }
    
    func setupSlideScrollView(slides : [Slide]) {
           myScrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
           myScrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: view.frame.height)
           myScrollView.isPagingEnabled = true
           
           for i in 0 ..< slides.count {
               slides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height)
               myScrollView.addSubview(slides[i])
           }
       }
}

extension OnBoardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
        
        if scrollView.contentOffset.y > 0 || scrollView.contentOffset.y < 0 {
           scrollView.contentOffset.y = 0
        }
    }
}
