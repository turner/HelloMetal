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

    let samplerState: MTLSamplerState

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
    var finalRenderPassDescriptor: MTLRenderPassDescriptor

    var commandQueue: MTLCommandQueue?

    init(view: MTKView, device: MTLDevice) {

        samplerState = RenderPassRenderer.buildSamplerState(device: device)

        guard let library = device.makeDefaultLibrary() else {
            fatalError("Error: Can not create default library")
        }

        // hero pipline state
        do {

            let pipelineDescriptor =
                    MTLRenderPipelineDescriptor(library:library, vertexShaderName:"textureVertexShader", fragmentShaderName:"textureWithSamplerFragmentShader", sampleCount:view.sampleCount, colorPixelFormat:view.colorPixelFormat, vertexDescriptor: nil)
            
            pipelineState = try device.makeRenderPipelineState(descriptor:pipelineDescriptor)

        } catch let e {
            Swift.print("\(e)")
        }

        // backdrop pipeline state
        do {

            let pipelineDescriptor =
                    MTLRenderPipelineDescriptor(library:library, vertexShaderName:"textureVertexShader", fragmentShaderName:"textureWithSamplerFragmentShader", sampleCount:view.sampleCount, colorPixelFormat:view.colorPixelFormat, vertexDescriptor: nil)
            
            backdropPipelineState = try device.makeRenderPipelineState(descriptor:pipelineDescriptor)
        } catch let e {
            Swift.print("\(e)")
        }

        // final pass pipline statate
        do {

            let pipelineDescriptor =
                    MTLRenderPipelineDescriptor(library:library, vertexShaderName:"finalPassVertexShader", fragmentShaderName:"finalPassOverlayWithSamplerFragmentShader", sampleCount:view.sampleCount, colorPixelFormat:view.colorPixelFormat, vertexDescriptor: nil)
             
            finalPassPipelineState = try device.makeRenderPipelineState(descriptor:pipelineDescriptor)
        } catch let e {
            Swift.print("\(e)")
        }


        finalRenderPassDescriptor = MTLRenderPassDescriptor()
        finalRenderPassDescriptor.EI_renderpass_configure(clearColor: MTLClearColorMake(0.25, 0.25, 0.25, 1), clearDepth: 1)


        guard let cq = device.makeCommandQueue() else {
            fatalError("Error: Can not create command queue")
        }

        commandQueue = cq

    }

    static func buildSamplerState(device: MTLDevice) -> MTLSamplerState {
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.normalizedCoordinates = true
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.mipFilter = .linear
        return device.makeSamplerState(descriptor: samplerDescriptor)!
    }

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        reshape(view:view as! EIView)
    }

    func reshape (view:EIView) {

        view.arcBall.reshape(viewBounds: view.bounds)

        camera.setProjection(fovYDegrees:Float(35), aspectRatioWidthOverHeight:Float(view.bounds.size.width/view.bounds.size.height), near:200, far: 8000)
        
        let scaleFactor = UIScreen.main.scale
        let ww = scaleFactor * view.bounds.size.width
        let hh = scaleFactor * view.bounds.size.height

        // color - multi-sample texture
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat:view.colorPixelFormat, width:Int(ww), height:Int(hh), mipmapped:false)
        textureDescriptor.mipmapLevelCount = 1;
        textureDescriptor.textureType = .type2DMultisample
        textureDescriptor.sampleCount = view.sampleCount
        textureDescriptor.usage = .renderTarget
        finalRenderPassDescriptor.colorAttachments[ 0 ].texture = view.device!.makeTexture(descriptor:textureDescriptor)

        // color - point-sample resolve texture
        let resolveTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat:view.colorPixelFormat, width:Int(ww), height:Int(hh), mipmapped:true)
        finalRenderPassDescriptor.colorAttachments[ 0 ].resolveTexture = view.device!.makeTexture(descriptor:resolveTextureDescriptor)

        // depth
        let depthTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat:.depth32Float, width:Int(ww), height:Int(hh), mipmapped:false)
        depthTextureDescriptor.mipmapLevelCount = 1;
        depthTextureDescriptor.textureType = .type2DMultisample
        depthTextureDescriptor.sampleCount = view.sampleCount
        depthTextureDescriptor.usage = .renderTarget
        finalRenderPassDescriptor.depthAttachment.texture = view.device!.makeTexture(descriptor:depthTextureDescriptor)
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

        guard let encoder = buffer.makeRenderCommandEncoder(descriptor: finalRenderPassDescriptor) else {
            fatalError("Error: Can not create command encoder")
        }

        // configure encoder
        encoder.setFrontFacing(.counterClockwise)
        encoder.setTriangleFillMode(.fill)
        encoder.setCullMode(.none)
        encoder.setFragmentSamplerState(samplerState, index: 0)

        // hero backdrop
        encoder.EI_configureWithTextures(renderPipelineState: backdropPipelineState, model: backdropModel, textures: [ backdropTexture ])

        // hero model
        encoder.EI_configureWithTextures(renderPipelineState: pipelineState, model: model, textures: [ texture ])

        encoder.endEncoding()

        // final pass
        if let descriptor = view.currentRenderPassDescriptor, let drawable = view.currentDrawable {

            descriptor.colorAttachments[ 0 ].clearColor = MTLClearColorMake(1, 1, 1, 1)

            guard let finalPassEncoder = buffer.makeRenderCommandEncoder(descriptor: descriptor) else {
                fatalError("Error: Can not create command encoder")
            }

            // configure final pass encoder
            finalPassEncoder.setFrontFacing(.counterClockwise)
            finalPassEncoder.setTriangleFillMode(.fill)
            finalPassEncoder.setCullMode(.none)
            finalPassEncoder.setFragmentSamplerState(samplerState, index: 0)

            let textures:[MTLTexture] =
                    [
                        finalRenderPassDescriptor.colorAttachments[ 0 ].resolveTexture!,
                        finalPassTexture
                    ]
            finalPassEncoder.EI_configureWithTextures(renderPipelineState: finalPassPipelineState, model: finalPassModel, textures: textures)

            finalPassEncoder.endEncoding()


            buffer.present(drawable)
            buffer.commit()
        }

    }

}
