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

    var renderer:OpenEXRRenderer!

    override func viewDidLoad() {
        super.viewDidLoad()

        eiViewDidLoad(view as! EIView)
    }

    func eiViewDidLoad(_ view:EIView) {

        renderer = OpenEXRRenderer(view: view, device: view.device!)
        view.delegate = renderer

        renderer.camera = EICamera(location:GLKVector3(v:(0, 0, 500)), target:GLKVector3(v:(0, 0, 0)), approximateUp:GLKVector3(v:(0, 1, 0)))

        renderer.model = EIMesh.plane(device: view.device!, xExtent: 200, zExtent: 200, xTesselation: 2, zTesselation: 2)

//        renderer.model = EIMesh.sceneMesh(device: view.device!, sceneName:"scenes.scnassets/teapot.scn", nodeName:"teapotIdentity")
//        renderer.model = EIMesh.sceneMesh(device: view.device!, sceneName:"scenes.scnassets/head.scn", nodeName:"headIdentity")
//        renderer.model = EIMesh.sceneMesh(device: view.device!, sceneName:"scenes.scnassets/bear.scn", nodeName:"bearIdentity")

        renderer.cameraPlane = EIMesh.plane(device: view.device!, xExtent: 2, zExtent: 2, xTesselation: 4, zTesselation: 4)

        renderer.texture = textureFromOpenEXR(device: view.device!, name: "alias_wavefront_diagnostic.exr")

        do {
            renderer.cameraPlaneTexture = try makeTexture(device: view.device!, name: "mobile")
        } catch {
            fatalError("Error: Can not load texture")
        }

        guard let library = view.device!.makeDefaultLibrary() else {
            fatalError("Error: Can not create default library")
        }

        do {

            let pipelineDescriptor =
                    MTLRenderPipelineDescriptor.EI_Create(library:library, vertexShaderName:"openEXRVertexShader", fragmentShaderName:"openEXRFragmentShader", sampleCount:view.sampleCount, colorPixelFormat:view.colorPixelFormat, vertexDescriptor: renderer.model.metalVertexDescriptor)

            renderer.pipelineState = try view.device!.makeRenderPipelineState(descriptor:pipelineDescriptor)
        } catch let e {
            Swift.print("\(e)")
        }

        do {

            let pipelineDescriptor =
                    MTLRenderPipelineDescriptor.EI_Create(library:library, vertexShaderName:"textureMIOVertexShader", fragmentShaderName:"textureMIOFragmentShader", sampleCount:view.sampleCount, colorPixelFormat:view.colorPixelFormat, vertexDescriptor: renderer.cameraPlane.metalVertexDescriptor)

            renderer.cameraPlanePipelineState = try view.device!.makeRenderPipelineState(descriptor: pipelineDescriptor)

        } catch let e {
            Swift.print("\(e)")
        }

    }

}
