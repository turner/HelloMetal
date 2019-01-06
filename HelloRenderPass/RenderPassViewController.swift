//
//  RenderPassViewController.swift
//  HelloRenderPass
//
//  Created by Douglass Turner on 11/24/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import UIKit
import GLKit

class RenderPassViewController: UIViewController {
    
    var scene = EIScene()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let eiview = view as! EIView
        scene.configure(view: eiview, renderer:EIRenderPassEngine(view: eiview, device: eiview.device!))
        
    }
    
}
