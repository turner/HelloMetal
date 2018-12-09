//
//  RenderEngine_Model_IO.swift
//  HelloModel_IO
//
//  Created by Douglass Turner on 12/9/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import MetalKit
import GLKit

class RendererEngine_Model_IO: RendererEngine {
    
    let depthStencilState: MTLDepthStencilState?
    
    override init(view: MTKView, device: MTLDevice) {
        
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = true
        
        guard let dss = device.makeDepthStencilState(descriptor: depthStencilDescriptor) else {
            fatalError("Error: Can not create depth stencil state")
        }
        
        depthStencilState = dss
        
        super.init(view: view, device: device)

    }
    
    public override func draw(in view: MTKView) {
        
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
