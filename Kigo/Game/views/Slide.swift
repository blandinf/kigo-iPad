//
//  Slide.swift
//  Kigo
//
//  Created by Florian on 09/05/2020.
//  Copyright © 2020 blandinf. All rights reserved.
//

import UIKit

class Slide: UIView {
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
}
