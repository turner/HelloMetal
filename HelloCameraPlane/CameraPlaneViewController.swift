//
//  CameraPlaneViewController.swift
//  HelloCameraPlane
//
//  Created by Douglass Turner on 11/23/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import UIKit
import GLKit

class CameraPlaneViewController: UIViewController {
    
    var renderer:RendererEngine!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        eiViewDidLoad(view as! EIView)
    }

    func eiViewDidLoad(_ view:EIView) {

        renderer = RendererEngine(view: view, device: view.device!)
        view.delegate = renderer

        renderer.camera = EICamera(location:GLKVector3(v:(0, 0, 1000)), target:GLKVector3(v:(0, 0, 0)), approximateUp:GLKVector3(v:(0, 1, 0)))

        var shader:EIShader
        
        // hero
        shader = EIShader(view:view, library:renderer.library!, vertex:"textureVertexShader", fragment:"textureFragmentShader", textureNames:["diagnostic"])
        let model = EIModel(model:EIQuad(device: view.device!), shader:shader, transformer:{
            return view.arcBall.rotationMatrix * GLKMatrix4MakeScale(150, 150, 1)
        })
        
        // cameraPlane
        shader = EIShader(view:view, library:renderer.library!, vertex:"textureVertexShader", fragment:"textureFragmentShader", textureNames:["mobile"])
        let cameraPlane = EIModel(model:EIQuad(device: view.device!), shader:shader, transformer:{
            return self.renderer.camera.createRenderPlaneTransform(distanceFromCamera: 0.75 * self.renderer.camera.far)
        })

        renderer.models.append(model)
        renderer.models.append(cameraPlane)

    }
}
