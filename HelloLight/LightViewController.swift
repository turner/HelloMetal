//
//  LightViewController.swift
//  HelloLight
//
//  Created by Douglass Turner on 12/2/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import UIKit
import GLKit

class LightViewController: UIViewController {

    var renderer:LightRenderer!

    override func viewDidLoad() {
        super.viewDidLoad()

        eiViewDidLoad(view as! EIView)
    }

    func eiViewDidLoad(_ view:EIView) {

        renderer = LightRenderer(view: view, device: view.device!)
        view.delegate = renderer

        renderer.camera = EICamera(location:GLKVector3(v:(0, 0, 500)), target:GLKVector3(v:(0, 0, 0)), approximateUp:GLKVector3(v:(0, 1, 0)))


        renderer.model = EIMesh.sceneMesh(device:view.device!, sceneName:"scenes.scnassets/high-res-head-no-groups.scn", nodeName:"highResHeadIdentity")

//        renderer.model = EIMesh.plane(    device:view.device!, xExtent: 200, zExtent: 200, xTesselation: 2, zTesselation: 2)

//        renderer.model = EIMesh.sceneMesh(device:view.device!, sceneName:"scenes.scnassets/teapot.scn", nodeName:"teapotIdentity")
//        renderer.model = EIMesh.sceneMesh(device:view.device!, sceneName:"scenes.scnassets/better_male_head.scn", nodeName:"betterHeadIdentity")

        // camera plane
        renderer.cameraPlane = EIMesh.plane(device: view.device!, xExtent: 2, zExtent: 2, xTesselation: 4, zTesselation: 4)

        do {
            renderer.texture = try makeTexture(device: view.device!, name: "swirl")
        } catch {
            fatalError("Error: Can not load texture")
        }

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
                    MTLRenderPipelineDescriptor.EI_Create(library:library, vertexShaderName:"litTextureMIOVertexShader", fragmentShaderName:"litTextureMIOFragmentShader", sampleCount:view.sampleCount, colorPixelFormat:view.colorPixelFormat, vertexDescriptor: renderer.model.metalVertexDescriptor)

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
