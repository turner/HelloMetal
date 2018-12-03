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

    var renderer:SceneKitRenderer!

    override func viewDidLoad() {
        super.viewDidLoad()

        eiViewDidLoad(view as! EIView)
    }

    func eiViewDidLoad(_ view:EIView) {

        renderer = SceneKitRenderer(view: view, device: view.device!)
        view.delegate = renderer

        renderer.camera = EICamera(location:GLKVector3(v:(0, 0, 1000)), target:GLKVector3(v:(0, 0, 0)), approximateUp:GLKVector3(v:(0, 1, 0)))

//        renderer.model = EIMesh.sceneMesh(device:device, sceneName:"scenes.scnassets/teapot.scn", nodeName:"teapotIdentity")

        renderer.model = EIMesh.sceneMesh(device:view.device!, sceneName:"scenes.scnassets/high-res-head-no-groups.scn", nodeName:"highResHeadIdentity")

        // camera plane
        renderer.cameraPlane = EIMesh.plane(device: view.device!, xExtent: 2, zExtent: 2, xTesselation: 4, zTesselation: 4)

        do {
            renderer.frontTexture = try makeTexture(device: view.device!, name: "blue_grey")
        } catch {
            fatalError("Error: Can not load texture")
        }

        do {
            renderer.backTexture = try makeTexture(device: view.device!, name: "show_st")
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

            // vertexShaderName:"textureTwoSidedMIOVertexShader",
            // fragmentShaderName:"textureTwoSidedMIOFragmentShader",

            let pipelineDescriptor =
                    MTLRenderPipelineDescriptor.EI_Create(library:library, vertexShaderName:"showMIOVertexShader", fragmentShaderName:"showMIOFragmentShader", sampleCount:view.sampleCount, colorPixelFormat:view.colorPixelFormat, vertexDescriptor: renderer.model.metalVertexDescriptor)

            renderer.pipelineState = try view.device!.makeRenderPipelineState(descriptor:pipelineDescriptor)
        } catch let e {
            Swift.print("\(e)")
        }

        do {

            let pipelineDescriptor =
                    MTLRenderPipelineDescriptor.EI_Create(library:library, vertexShaderName:"textureTwoSidedMIOVertexShader", fragmentShaderName:"textureTwoSidedMIOFragmentShader", sampleCount:view.sampleCount, colorPixelFormat:view.colorPixelFormat, vertexDescriptor: renderer.cameraPlane.metalVertexDescriptor)

            renderer.cameraPlanePipelineState = try view.device!.makeRenderPipelineState(descriptor: pipelineDescriptor)

        } catch let e {
            Swift.print("\(e)")
        }

    }

}
