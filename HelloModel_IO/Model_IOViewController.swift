//
//  Model_IOViewController.swift
//  HelloModel_IO
//
//  Created by Douglass Turner on 11/30/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import UIKit
import GLKit

class Model_IOViewController: EIViewController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let eiview = view as! EIView
        scene.configure(view: eiview, renderer:EIRendererEngine(view: eiview, device: eiview.device!))
        
    }

}
