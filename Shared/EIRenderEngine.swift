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
        
        depthStencilState = device.EIMakeDepthStencilState()
        
        commandQueue = device.EIMakeCommandQueue()
                
        samplerState = device.EIMakeSamplerState()
        
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
        
        for model in models {
            model.update(camera: camera)
        }
        
    }

    func renderPass(commandBuffer:MTLCommandBuffer, renderPassDescriptor:MTLRenderPassDescriptor) {
        
        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            fatalError("Error: Can not create command encoder")
        }
        
        // configure encoder
        encoder.setDepthStencilState(depthStencilState)
        encoder.setFrontFacing(.counterClockwise)
        encoder.setTriangleFillMode(.fill)
        encoder.setCullMode(.none)
        encoder.setFragmentSamplerState(samplerState, index: 0)
        
        for model in models {
            model.encode(encoder: encoder)
        }
        
        encoder.endEncoding()
        
    }

    public func draw(in view: MTKView) {
        
        update(view: view as! EIView, drawableSize: view.bounds.size)

        guard let passDescriptor = view.currentRenderPassDescriptor else {
            fatalError("Error: view.currentRenderPassDescriptor is nil")
        }
 
        guard let buffer = commandQueue!.makeCommandBuffer() else {
            fatalError("Error: Can not create command buffer")
        }

        renderPass(commandBuffer:buffer, renderPassDescriptor:passDescriptor)

        guard let drawable = view.currentDrawable else {
            fatalError("Error: view.currentDrawable is nil")
        }
        
        buffer.present(drawable)
        buffer.commit()
        
    }
    
    
}
