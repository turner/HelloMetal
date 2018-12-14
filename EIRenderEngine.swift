//
//  EIRenderEngine.swift
//  HelloMetal
//
//  Created by Douglass Turner on 12/9/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import MetalKit
import GLKit

class EIRendererEngine: NSObject, MTKViewDelegate {
    
    var camera:EICamera!
    
    var models:[EIModel] = [EIModel]()
    
    let depthStencilState: MTLDepthStencilState?
    let commandQueue:MTLCommandQueue?
    let samplerState: MTLSamplerState?
    let view:MTKView
    
    init(view: EIView, device: MTLDevice) {
 
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = true
        
        guard let dss = device.makeDepthStencilState(descriptor: depthStencilDescriptor) else {
            fatalError("Error: Can not create depth stencil state")
        }
        
        depthStencilState = dss

        guard let cq = device.makeCommandQueue() else {
            fatalError("Error: Can not create command queue")
        }
        
        commandQueue = cq
        
        guard let ss = MTLSamplerDescriptor.EI_CreateMipMapSamplerState(device: device) else {
            fatalError("Error: Can not create sampler state ")
        }
        
        samplerState = ss
        
        self.view = view
    }
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        reshape(view:view as! EIView)
    }
    
    func reshape (view: EIView) {
        view.arcBall.reshape(viewBounds: view.bounds)
        camera.setProjection(fovYDegrees:Float(35), aspectRatioWidthOverHeight:Float(view.bounds.size.width / view.bounds.size.height), near: 100, far: 8000)
    }
    
    func update(view: EIView, drawableSize:CGSize) {
        
        for var model in models {
            model.update(camera: camera, arcball: view.arcBall)
        }
        
    }
    
    public func draw(in view: MTKView) {
        
        update(view: view as! EIView, drawableSize: view.bounds.size)
        
        if let passDescriptor = view.currentRenderPassDescriptor, let drawable = view.currentDrawable {
            
            passDescriptor.colorAttachments[ 0 ].clearColor = MTLClearColorMake(0.5, 0.5, 0.5, 1.0)
            
            guard let buffer = commandQueue!.makeCommandBuffer() else {
                fatalError("Error: Can not create command buffer")
            }
            
            guard let encoder = buffer.makeRenderCommandEncoder(descriptor: passDescriptor) else {
                fatalError("Error: Can not create command encoder")
            }
            
            encoder.setDepthStencilState(depthStencilState)
            encoder.setFrontFacing(.counterClockwise)
            encoder.setTriangleFillMode(.fill)
            encoder.setCullMode(.none)
            encoder.setFragmentSamplerState(samplerState, index: 0)
            
            for model in models {
                model.encode(encoder: encoder)
            }

            encoder.endEncoding()
            
            buffer.present(drawable)
            buffer.commit()
        }
        
    }
    
    
}
