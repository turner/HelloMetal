//
//  HelloRenderer.swift
//  HelloMetal
//
//  Created by Douglass Turner on 9/11/16.
//  Copyright © 2016 Elastic Image Software. All rights reserved.
//

import MetalKit
import GLKit

class HelloRenderer: NSObject, MTKViewDelegate {

    var camera:EICamera!
    var model: EIQuad!
    var texture:MTLTexture!
    
    var pipelineState:MTLRenderPipelineState!

    let commandQueue:MTLCommandQueue?
    let samplerState: MTLSamplerState?

    init(view: MTKView, device: MTLDevice) {

        guard let cq = device.makeCommandQueue() else {
            fatalError("Error: Can not create command queue")
        }
        
        commandQueue = cq

        guard let ss = MTLSamplerDescriptor.EI_CreateMipMapSamplerState(device: device) else {
            fatalError("Error: Can not create sampler state ")
        }

        samplerState = ss

        guard let library = device.makeDefaultLibrary() else {
            fatalError("Error: Can not create default library")
        }
    
        let pipelineDescriptor =
                MTLRenderPipelineDescriptor.EI_Create(library:library, vertexShaderName:"textureVertexShader", fragmentShaderName:"textureFragmentShader", sampleCount:view.sampleCount, colorPixelFormat:view.colorPixelFormat, vertexDescriptor: nil)

        do {
            pipelineState = try device.makeRenderPipelineState(descriptor:pipelineDescriptor)
        } catch let e {
            Swift.print("\(e)")
        }
    }

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        reshape(view:view as! EIView)
    }

    func reshape (view: EIView) {
        view.arcBall.reshape(viewBounds: view.bounds)
        camera.setProjection(fovYDegrees:Float(35), aspectRatioWidthOverHeight:Float(view.bounds.size.width / view.bounds.size.height), near: 200, far: 8000)
    }

    func update(view: EIView, drawableSize:CGSize) {

        model.metallicTransform.update(camera: camera, transformer: {
            return view.arcBall.rotationMatrix * GLKMatrix4MakeScale(150, 150, 1)
        })

    }

    public func draw(in view: MTKView) {

        update(view: view as! EIView, drawableSize: view.bounds.size)

        // final pass
        if let passDescriptor = view.currentRenderPassDescriptor, let drawable = view.currentDrawable {

            passDescriptor.colorAttachments[ 0 ].clearColor = MTLClearColorMake(0.5, 0.5, 0.5, 1.0)

            guard let buffer = commandQueue!.makeCommandBuffer() else {
                fatalError("Error: Can not create command buffer")
            }

            guard let encoder = buffer.makeRenderCommandEncoder(descriptor: passDescriptor) else {
                fatalError("Error: Can not create command encoder")
            }

            encoder.setFrontFacing(.counterClockwise)
            encoder.setTriangleFillMode(.fill)
            encoder.setCullMode(.none)
            encoder.setFragmentSamplerState(samplerState, index: 0)

            encoder.EI_Configure(renderPipelineState: pipelineState, model: model, textures: [texture])

            encoder.endEncoding()

            buffer.present(drawable)
            buffer.commit()
        }

    }

}
