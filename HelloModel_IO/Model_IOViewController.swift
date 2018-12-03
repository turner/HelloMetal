//
//  Model_IOViewController.swift
//  HelloModel_IO
//
//  Created by Douglass Turner on 11/30/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import UIKit
import GLKit

class Model_IOViewController: UIViewController {

    var renderer:Model_IORenderer!

    override func viewDidLoad() {
        super.viewDidLoad()

        eiViewDidLoad(view as! EIView)
    }

    func eiViewDidLoad(_ view:EIView) {

        renderer = Model_IORenderer(view: view, device: view.device!)
        view.delegate = renderer

        renderer.camera = EICamera(location:GLKVector3(v:(0, 0, 1000)), target:GLKVector3(v:(0, 0, 0)), approximateUp:GLKVector3(v:(0, 1, 0)))

        // heroModel = EIMesh.plane(device: view.device!, xExtent: 200, zExtent: 200, xTesselation: 2, zTesselation: 2)
        // heroModel = EIMesh.sphere(device: view.device!, xRadius: 150, yRadius: 150, zRadius: 150, uTesselation: 32, vTesselation: 32)
        renderer.model = EIMesh.cube(device: view.device!, xExtent: 200, yExtent: 100, zExtent: 200, xTesselation: 32, yTesselation: 32, zTesselation: 32)

        // camera plane
        renderer.cameraPlane = EIMesh.plane(device: view.device!, xExtent: 2, zExtent: 2, xTesselation: 4, zTesselation: 4)

        do {
            renderer.texture = try makeTexture(device: view.device!, name: "mandrill")
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

            // vertexShaderName:"litTextureMIOVertexShader",
            // fragmentShaderName:"litTextureMIOFragmentShader",

            let pipelineDescriptor =
                    MTLRenderPipelineDescriptor.EI_Create(library:library, vertexShaderName:"textureMIOVertexShader", fragmentShaderName:"textureMIOFragmentShader", sampleCount:view.sampleCount, colorPixelFormat:view.colorPixelFormat, vertexDescriptor: renderer.model.metalVertexDescriptor)

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
