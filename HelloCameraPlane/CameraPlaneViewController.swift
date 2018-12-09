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
        let hq = EIQuad(device: view.device!)
        shader = EIShader(view:view, library:renderer.library!, vertex:"textureVertexShader", fragment:"textureFragmentShader", textureNames:["diagnostic"], vertexDescriptor: nil)

        let hero = EIModel(model:hq, shader:shader, transformer:{
            return view.arcBall.rotationMatrix * GLKMatrix4MakeScale(150, 150, 1)
        })
        
        // cameraPlane
        
//        let cpq = EIQuad(device: view.device!)
//        shader = EIShader(view:view, library:renderer.library!, vertex:"textureVertexShader", fragment:"textureFragmentShader", textureNames:["mobile"], vertexDescriptor:nil)
        
        let plane = EIMesh.plane(device: view.device!, xExtent: 2, zExtent: 2, xTesselation: 4, zTesselation: 4)
        shader = EIShader(view:view, library:renderer.library!, vertex:"textureMIOVertexShader", fragment:"textureMIOFragmentShader", textureNames:["mobile"], vertexDescriptor: plane.metalVertexDescriptor)

        let cameraPlane = EIModel(model:plane, shader:shader, transformer:{

            // EIQuad
//            return self.renderer.camera.createRenderPlaneTransform(distanceFromCamera: 0.75 * self.renderer.camera.far)

            // EIMesh.plane
            return self.renderer.camera.createRenderPlaneTransform(distanceFromCamera: 0.75 * self.renderer.camera.far) * GLKMatrix4MakeRotation(GLKMathDegreesToRadians(90), 1, 0, 0)
        })

        renderer.models.append(hero)
        renderer.models.append(cameraPlane)

    }
}
