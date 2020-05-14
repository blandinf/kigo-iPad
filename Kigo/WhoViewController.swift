//
//  WhoViewController.swift
//  Kigo
//
//  Created by Florian on 14/05/2020.
//  Copyright © 2020 blandinf. All rights reserved.
//

import UIKit

class WhoViewController: UIViewController {
    var childrens = [Child]()
    @IBOutlet weak var childSelected: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
}
