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

    var renderer:EIRenderPassEngine!

    override func viewDidLoad() {
        super.viewDidLoad()

        eiViewDidLoad(view as! EIView)
    }

    func eiViewDidLoad(_ view:EIView) {

        var shader:EIShader
        
        renderer = EIRenderPassEngine(view: view, device: view.device!)
        view.delegate = renderer

        renderer.camera = EICamera(location:GLKVector3(v:(0, 0, 1000)), target:GLKVector3(v:(0, 0, 0)), approximateUp:GLKVector3(v:(0, 1, 0)))

        // hero
        shader = EIShader(view:view, library:view.defaultLibrary, vertex:"textureVertexShader", fragment:"textureFragmentShader", textureNames:["kids_grid_3x3_translucent"], vertexDescriptor: nil)
        let hero = EIModel(model:EIQuad(device: view.device!), shader:shader, transformer:{
            return view.arcBall.rotationMatrix * GLKMatrix4MakeScale(150, 150, 1)
        })

        // camera plane
        shader = EIShader(view:view, library:view.defaultLibrary, vertex:"textureVertexShader", fragment:"textureFragmentShader", textureNames:["mobile"], vertexDescriptor: nil)
        let cameraPlane = EIModel(model:EIQuad(device: view.device!), shader:shader, transformer:{ [unowned self] in
            return self.renderer.camera.createRenderPlaneTransform(distanceFromCamera: 0.35 * self.renderer.camera.far)
        })

        renderer.models.append(cameraPlane)
        renderer.models.append(hero)

    }

}
