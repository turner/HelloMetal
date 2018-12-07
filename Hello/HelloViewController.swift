//
//  HelloViewController.swift
//  Hello
//
//  Created by Douglass Turner on 11/22/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import UIKit
import GLKit

class HelloViewController: UIViewController {
 
    var renderer:HelloRenderer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        eiViewDidLoad(view as! EIView)
    }
    
    func eiViewDidLoad(_ view:EIView) {
        
        renderer = HelloRenderer(view: view, device: view.device!)
        view.delegate = renderer

        renderer.camera = EICamera(location:GLKVector3(v:(0, 0, 1000)), target:GLKVector3(v:(0, 0, 0)), approximateUp:GLKVector3(v:(0, 1, 0)))
        
        renderer.model = EIQuad(device: view.device!);

        do {
            renderer.texture = try makeTexture(device: view.device!, name: "kids_grid_3x3")
        } catch {
            fatalError("Error: Can not load texture")
        }

        let pipelineDescriptor =
            MTLRenderPipelineDescriptor.EI_Create(library:renderer.library!, vertexShaderName:"textureVertexShader", fragmentShaderName:"textureFragmentShader", sampleCount:view.sampleCount, colorPixelFormat:view.colorPixelFormat, vertexDescriptor: nil)
        
        do {
            renderer.pipelineState = try view.device!.makeRenderPipelineState(descriptor:pipelineDescriptor)
        } catch let e {
            Swift.print("\(e)")
        }

    }
    
}
