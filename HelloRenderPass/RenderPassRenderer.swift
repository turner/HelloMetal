//
//  RenderPassRenderer.swift
//  HelloMetal
//
//  Created by Douglass Turner on 9/11/16.
//  Copyright © 2016 Elastic Image Software. All rights reserved.
//

import MetalKit
import GLKit

class RenderPassRenderer: NSObject, MTKViewDelegate {

    var camera: EICamera!

    // hero model
    var model: EIQuad!
    var texture: MTLTexture!
    var pipelineState: MTLRenderPipelineState!

    // hero backdrop
    var backdropModel: EIQuad!
    var backdropTexture: MTLTexture!
    var backdropPipelineState: MTLRenderPipelineState!

    // final pass
    var finalPassModel: EIQuad!
    var finalPassTexture: MTLTexture!
    var finalPassPipelineState: MTLRenderPipelineState!

    // render to texture
    var finalPassDescriptor: MTLRenderPassDescriptor

    var commandQueue: MTLCommandQueue?

    init(view: MTKView, device: MTLDevice) {

        guard let library = device.makeDefaultLibrary() else {
            fatalError("Error: Can not create default library")
        }

        // hero pipline state
        do {

            let pipelineDescriptor =
                    MTLRenderPipelineDescriptor(library:library, vertexShaderName:"textureVertexShader", fragmentShaderName:"textureFragmentShader", sampleCount:view.sampleCount, colorPixelFormat:view.colorPixelFormat, vertexDescriptor: nil)

            pipelineState = try device.makeRenderPipelineState(descriptor:pipelineDescriptor)

        } catch let e {
            Swift.print("\(e)")
        }

        // backdrop pipeline state
        do {

            let pipelineDescriptor =
                    MTLRenderPipelineDescriptor(library:library, vertexShaderName:"textureVertexShader", fragmentShaderName:"textureFragmentShader", sampleCount:view.sampleCount, colorPixelFormat:view.colorPixelFormat, vertexDescriptor: nil)

            backdropPipelineState = try device.makeRenderPipelineState(descriptor:pipelineDescriptor)
        } catch let e {
            Swift.print("\(e)")
        }

        // final pass pipline statate
        do {

            finalPassDescriptor = MTLRenderPassDescriptor(clearColor:MTLClearColorMake(1, 1, 1, 1), clearDepth:1)

            let pipelineDescriptor =
                    MTLRenderPipelineDescriptor(library:library, vertexShaderName:"finalPassVertexShader", fragmentShaderName:"finalPassOverlayFragmentShader", sampleCount:view.sampleCount, colorPixelFormat:view.colorPixelFormat, vertexDescriptor: nil)

            finalPassPipelineState = try device.makeRenderPipelineState(descriptor:pipelineDescriptor)
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

    func reshape (view:EIView) {

        view.arcBall.reshape(viewBounds: view.bounds)

        camera.setProjection(fovYDegrees:Float(35), aspectRatioWidthOverHeight:Float(view.bounds.size.width/view.bounds.size.height), near:200, far: 8000)

        // color
        let rgbaTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat:view.colorPixelFormat, width:Int(view.bounds.size.width), height:Int(view.bounds.size.height), mipmapped:true)
        rgbaTextureDescriptor.usage = [.renderTarget, .shaderRead]
        finalPassDescriptor.colorAttachments[ 0 ].texture = view.device!.makeTexture(descriptor:rgbaTextureDescriptor)

        // depth
        let depthTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat:.depth32Float, width:Int(view.bounds.size.width), height:Int(view.bounds.size.height), mipmapped:false)
        depthTextureDescriptor.usage = .renderTarget
        finalPassDescriptor.depthAttachment.texture = view.device!.makeTexture(descriptor:depthTextureDescriptor)
    }

    func update(view:EIView, drawableSize:CGSize) {

        // render plane
        finalPassModel.metallicTransform.update(camera: camera, transformer: {
            return camera.createRenderPlaneTransform(distanceFromCamera: 0.75 * camera.far)
        })

        // hero model
        model.metallicTransform.update(camera: camera, transformer: {
            return view.arcBall.rotationMatrix * GLKMatrix4MakeScale(150, 150, 1)
        })

        // hero backdrop
        backdropModel.metallicTransform.update(camera: camera, transformer: {
            return camera.createRenderPlaneTransform(distanceFromCamera: 0.35 * camera.far)
        })

    }

    public func draw(in view: MTKView) {

        update(view: view as! EIView, drawableSize: view.bounds.size)

        guard let buffer = commandQueue!.makeCommandBuffer() else {
            fatalError("Error: Can not create command buffer")
        }

        guard let encoder = buffer.makeRenderCommandEncoder(descriptor: finalPassDescriptor) else {
            fatalError("Error: Can not create command encoder")
        }

        // configure encoder
        encoder.setFrontFacing(.counterClockwise)
        encoder.setTriangleFillMode(.fill)
        encoder.setCullMode(.none)

        // hero backdrop
        encoder.EI_configure(renderPipelineState: backdropPipelineState, model: backdropModel, texture: backdropTexture)

        // hero model
        encoder.EI_configure(renderPipelineState: pipelineState, model: model, texture: texture)

        encoder.endEncoding()

        // final pass
        if let finalPassDescriptor = view.currentRenderPassDescriptor, let drawable = view.currentDrawable {

            finalPassDescriptor.colorAttachments[ 0 ].clearColor = MTLClearColorMake(1, 1, 1, 1)

            guard let finalPassCommandEncoder = buffer.makeRenderCommandEncoder(descriptor: finalPassDescriptor) else {
                fatalError("Error: Can not create command encoder")
            }

            // configure final pass encoder
            finalPassCommandEncoder.setFrontFacing(.counterClockwise)
            finalPassCommandEncoder.setTriangleFillMode(.fill)
            finalPassCommandEncoder.setCullMode(.none)

            finalPassCommandEncoder.EI_configure(renderPipelineState: finalPassPipelineState, model: finalPassModel, texture: finalPassDescriptor.colorAttachments[ 0 ].texture!)

            finalPassCommandEncoder.endEncoding()

            buffer.present(drawable)
            buffer.commit()
        }

    }

}
