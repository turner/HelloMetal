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

    override func eiViewDidLoad(view:EIView) {

        renderer = EIRendererEngine(view: view, device: view.device!)
        view.delegate = renderer

        renderer.camera = EICamera(location:GLKVector3(v:(0, 0, 1000)), target:GLKVector3(v:(0, 0, 0)), approximateUp:GLKVector3(v:(0, 1, 0)))

        var shader:EIShader

        // hero
        let cube = EIMesh.cube(device: view.device!, xExtent: 200, yExtent: 100, zExtent: 200, xTesselation: 32, yTesselation: 32, zTesselation: 32)
        shader = EIShader(device:view.device!, vertex:"model_io_texture_vertex", fragment:"model_io_texture_fragment", textureNames:["mandrill"])

        let hero = EIModel(view:view, model:cube, shader:shader, transformer:{
            return view.arcBall.rotationMatrix
        })

        // camera plane
        let plane = EIMesh.plane(device: view.device!, xExtent: 2, zExtent: 2, xTesselation: 4, zTesselation: 4)
        shader = EIShader(device: view.device!, vertex:"model_io_texture_vertex", fragment:"model_io_texture_fragment", textureNames:["mobile"])

        let cameraPlane = EIModel(view:view, model:plane, shader:shader, transformer:{ [unowned self] in
            return self.renderer.camera.createRenderPlaneTransform(distanceFromCamera: 0.75 * self.renderer.camera.far) * GLKMatrix4MakeRotation(GLKMathDegreesToRadians(90), 1, 0, 0)
        })

        renderer.models.append(hero)
        renderer.models.append(cameraPlane)

    }

}
