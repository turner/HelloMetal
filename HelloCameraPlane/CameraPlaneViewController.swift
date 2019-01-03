//
//  CameraPlaneViewController.swift
//  HelloCameraPlane
//
//  Created by Douglass Turner on 11/23/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import UIKit
import GLKit

class CameraPlaneViewController: EIViewController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let eiview = view as! EIView
        scene.configure(view: eiview, renderer:EIRendererEngine(view: eiview, device: eiview.device!))
        
    }
    
}
