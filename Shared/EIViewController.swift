//
//  EIViewController.swift
//  HelloMetal
//
//  Created by Douglass Turner on 12/28/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import UIKit

class EIViewController : UIViewController {
    
    var scene = EIScene()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let eiview = view as! EIView
        scene.configure(view: eiview, renderer:EIRendererEngine(view: eiview, device: eiview.device!))
        
    }

}
