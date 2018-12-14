//
//  SceneKitViewController.swift
//  HelloSceneKit
//
//  Created by Douglass Turner on 12/3/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import UIKit
import GLKit

class SceneKitViewController: UIViewController {

    var renderer:EIRendererEngine!

    override func viewDidLoad() {
        super.viewDidLoad()

        eiViewDidLoad(view as! EIView)
    }

    func eiViewDidLoad(_ view:EIView) {

        renderer = EIRendererEngine(view: view, device: view.device!)
        view.delegate = renderer

        renderer.camera = EICamera(location:GLKVector3(v:(0, 0, 1000)), target:GLKVector3(v:(0, 0, 0)), approximateUp:GLKVector3(v:(0, 1, 0)))

        var shader:EIShader

        // hero

        // hi-res head
        let   heroMesh = EIMesh.sceneMesh(device:view.device!, sceneName:"scenes.scnassets/high-res-head-no-groups.scn", nodeName:"highResHeadIdentity")

        // teapot
//        let heroMesh = EIMesh.sceneMesh(device:view.device!, sceneName:"scenes.scnassets/teapot.scn",                  nodeName:"teapotIdentity")

        shader = EIShader(view:view, library:view.defaultLibrary, vertex:"showMIOVertexShader", fragment:"showMIOFragmentShader", textureNames:[], vertexDescriptor: heroMesh.metalVertexDescriptor)

        let hero = EIModel(model:heroMesh, shader:shader, transformer:{

            // default
//            return view.arcBall.rotationMatrix

            // scale for head (hi-res)
            return view.arcBall.rotationMatrix * GLKMatrix4MakeScale(750, 750, 750) * GLKMatrix4MakeTranslation(0.0, 0.075, 0.101)

            // scale for teapot
//            return view.arcBall.rotationMatrix * GLKMatrix4MakeScale(250, 250, 250)
        })


        // camera plane
        let cameraPlaneMesh = EIMesh.plane(device: view.device!, xExtent: 2, zExtent: 2, xTesselation: 4, zTesselation: 4)
        shader = EIShader(view:view, library:view.defaultLibrary, vertex:"textureMIOVertexShader", fragment:"textureMIOFragmentShader", textureNames:["mobile"], vertexDescriptor: cameraPlaneMesh.metalVertexDescriptor)

        let cameraPlane = EIModel(model:cameraPlaneMesh, shader:shader, transformer:{ [unowned self] in
            return self.renderer.camera.createRenderPlaneTransform(distanceFromCamera: 0.75 * self.renderer.camera.far) * GLKMatrix4MakeRotation(GLKMathDegreesToRadians(90), 1, 0, 0)
        })

        renderer.models.append(hero)
        renderer.models.append(cameraPlane)

    }

}
