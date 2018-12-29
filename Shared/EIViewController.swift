//
//  EIViewController.swift
//  HelloMetal
//
//  Created by Douglass Turner on 12/28/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import UIKit

class EIViewController: UIViewController {
    
    var renderer:EIRendererEngine!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        eiViewDidLoad(view: view as! EIView)
    }

    func eiViewDidLoad(view: EIView) {
        fatalError("Error: eiViewDidLoad(...). Base method call.")
    }
}
