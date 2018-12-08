//
//  HelloViewController.swift
//  Hello
//
//  Created by Douglass Turner on 11/22/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import UIKit
import GLKit

class HelloViewController: UIViewController {
 
    var renderer:HelloRenderer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eiViewDidLoad(view as! EIView)
    }
    
    func eiViewDidLoad(_ view:EIView) {
        
        renderer = HelloRenderer(view: view, device: view.device!)
        view.delegate = renderer

        renderer.camera = EICamera(location:GLKVector3(v:(0, 0, 1000)), target:GLKVector3(v:(0, 0, 0)), approximateUp:GLKVector3(v:(0, 1, 0)))
        
        let shader = EIShader(view:view, library:renderer.library!, vertex:"textureVertexShader", fragment:"textureFragmentShader", textureNames:["kids_grid_3x3"])
        
        renderer.model = EIModel(model:EIQuad(device: view.device!), shader:shader, transformer:{
            return GLKMatrix4MakeScale(150, 150, 1)
        })
    }
    
}
