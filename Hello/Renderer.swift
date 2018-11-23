//
//  Renderer.swift
//  HelloMetal
//
//  Created by Douglass Turner on 9/11/16.
//  Copyright © 2016 Elastic Image Software. All rights reserved.
//

import MetalKit
import GLKit

class Renderer: NSObject, MTKViewDelegate {

    var camera:EICamera!
    var model: EIQuad!
    var texture:MTLTexture!
    
    var pipelineState:MTLRenderPipelineState!

    var commandQueue:MTLCommandQueue?

    init(view: MTKView, device: MTLDevice) {

        guard let library = device.makeDefaultLibrary() else {
            fatalError("Error: Can not create default library")
        }
        
        // vertexShaderName:"showSTVertexShader",
        // fragmentShaderName:"showSTFragmentShader",
        let pipelineDescriptor =
                MTLRenderPipelineDescriptor(view:view, library:library, vertexShaderName:"textureVertexShader", fragmentShaderName:"textureFragmentShader", doIncludeDepthAttachment: false, vertexDescriptor: nil)

        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float;

        do {
            pipelineState = try device.makeRenderPipelineState(descriptor:pipelineDescriptor)
        } catch let e {
            Swift.print("\(e)")
        }

        guard let cq = device.makeCommandQueue() else {
            fatalError("Error: Can not create command queue")
        }

        commandQueue = cq
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
//            passDescriptor.colorAttachments[ 0 ].clearColor = MTLClearColorMake(1,1,1,1)

            guard let buffer = commandQueue!.makeCommandBuffer() else {
                fatalError("Error: Can not create command buffer")
            }

            guard let encoder = buffer.makeRenderCommandEncoder(descriptor: passDescriptor) else {
                fatalError("Error: Can not create command encoder")
            }

            encoder.setFrontFacing(.counterClockwise)

            encoder.setTriangleFillMode(.fill)
//            renderCommandEncoder.setTriangleFillMode(.lines)

            encoder.setRenderPipelineState(pipelineState)
            encoder.setVertexBuffer(model.vertexMetalBuffer, offset: 0, index: 0)
            encoder.setVertexBuffer(model.metallicTransform.metalBuffer, offset: 0, index: 1)
            encoder.setFragmentTexture(texture, index: 0)
            encoder.drawIndexedPrimitives(type: .triangle, indexCount: model.indexCount, indexType: MTLIndexType.uint16, indexBuffer: model.vertexIndexMetalBuffer, indexBufferOffset: 0)

            encoder.endEncoding()

            buffer.present(drawable)
            buffer.commit()
        }

    }

}
