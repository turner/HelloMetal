//
//  HelloViewController.swift
//  Hello
//
//  Created by Douglass Turner on 11/22/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import UIKit
import GLKit

class HelloViewController: EIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let eiview = view as! EIView
        scene = EIScene_Hello(view: eiview, renderer:EIRendererEngine(view: eiview, device: eiview.device!))
    }

}
