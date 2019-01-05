//
//  LightViewController.swift
//  HelloLight
//
//  Created by Douglass Turner on 12/2/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import UIKit
import GLKit

class LightViewController: EIViewController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let eiview = view as! EIView
        scene.configure(view: eiview, renderer:EIRendererEngine(view: eiview, device: eiview.device!))
        
    }
    
}
