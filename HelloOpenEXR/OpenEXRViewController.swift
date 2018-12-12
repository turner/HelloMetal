//
//  OpenEXRViewController.swift
//  HelloOpenEXR
//
//  Created by Douglass Turner on 12/5/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import UIKit
import GLKit

class OpenEXRViewController: UIViewController {

    var renderer:RendererEngine!

    override func viewDidLoad() {
        super.viewDidLoad()

        eiViewDidLoad(view as! EIView)
    }

    func eiViewDidLoad(_ view:EIView) {

        renderer = RendererEngine(view: view, device: view.device!)
        view.delegate = renderer

        renderer.camera = EICamera(location:GLKVector3(v:(0, 0, 500)), target:GLKVector3(v:(0, 0, 0)), approximateUp:GLKVector3(v:(0, 1, 0)))

        var shader:EIShader

        // hero
        let heroMesh = EIMesh.plane(device: view.device!, xExtent: 200, zExtent: 200, xTesselation: 2, zTesselation: 2)
        
//        let openEXRTexture = EIOpenEXRTexture(device: view.device!, name:"alias_wavefront_diagnostic.exr")
        let openEXRTexture = EIOpenEXRTexture(device: view.device!, name:"mandrill.exr")
        shader = EIShader(view:view, library:renderer.library!, vertex:"openEXRVertexShader", fragment:"openEXRFragmentShader", openEXRTexture:openEXRTexture, vertexDescriptor: heroMesh.metalVertexDescriptor)

        let hero = EIModel(model:heroMesh, shader:shader, transformer:{
            return view.arcBall.rotationMatrix * GLKMatrix4MakeRotation(GLKMathDegreesToRadians(90), 1, 0, 0)
        })


        // camera plane
        let cameraPlaneMesh = EIMesh.plane(device: view.device!, xExtent: 2, zExtent: 2, xTesselation: 4, zTesselation: 4)
        shader = EIShader(view:view, library:renderer.library!, vertex:"textureMIOVertexShader", fragment:"textureMIOFragmentShader", textureNames:["mobile"], vertexDescriptor: cameraPlaneMesh.metalVertexDescriptor)

        let cameraPlane = EIModel(model:cameraPlaneMesh, shader:shader, transformer:{
            return self.renderer.camera.createRenderPlaneTransform(distanceFromCamera: 0.75 * self.renderer.camera.far) * GLKMatrix4MakeRotation(GLKMathDegreesToRadians(90), 1, 0, 0)
        })

        renderer.models.append(hero)
        renderer.models.append(cameraPlane)

    }

}
