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

    var camera:EICamera!

    var model: EIModel!
    var cameraPlane: EIModel!
    var finalPassModel: EIModel!

    // render to texture
    var renderToTextureRenderPassDescriptor: MTLRenderPassDescriptor

    let library: MTLLibrary?
    let commandQueue:MTLCommandQueue?
    let samplerState: MTLSamplerState?

    init(view: MTKView, device: MTLDevice) {

        guard let dl = view.device!.makeDefaultLibrary() else {
            fatalError("Error: Can not create default library")
        }

        library = dl

        guard let cq = device.makeCommandQueue() else {
            fatalError("Error: Can not create command queue")
        }

        commandQueue = cq

        guard let ss = MTLSamplerDescriptor.EI_CreateMipMapSamplerState(device: device) else {
            fatalError("Error: Can not create sampler state ")
        }

        samplerState = ss

        renderToTextureRenderPassDescriptor = MTLRenderPassDescriptor()
        renderToTextureRenderPassDescriptor.EI_Configure(clearColor: MTLClearColorMake(0.25, 0.25, 0.25, 1), clearDepth: 1)

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
        renderToTextureRenderPassDescriptor.colorAttachments[ 0 ].texture = view.device!.makeTexture(descriptor:textureDescriptor)

        // color - point-sample resolve texture
        let resolveTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat:view.colorPixelFormat, width:Int(ww), height:Int(hh), mipmapped:true)
        renderToTextureRenderPassDescriptor.colorAttachments[ 0 ].resolveTexture = view.device!.makeTexture(descriptor:resolveTextureDescriptor)

        // depth
        let depthTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat:.depth32Float, width:Int(ww), height:Int(hh), mipmapped:false)
        depthTextureDescriptor.mipmapLevelCount = 1;
        depthTextureDescriptor.textureType = .type2DMultisample
        depthTextureDescriptor.sampleCount = view.sampleCount
        depthTextureDescriptor.usage = .renderTarget
        renderToTextureRenderPassDescriptor.depthAttachment.texture = view.device!.makeTexture(descriptor:depthTextureDescriptor)
    }

    func update(view:EIView, drawableSize:CGSize) {

        // camera plane
        cameraPlane.update(camera: camera, arcball: view.arcBall)

        // hero model
        model.update(camera: camera, arcball: view.arcBall)

        // final pass
        finalPassModel.update(camera: camera, arcball: view.arcBall)

    }

    public func draw(in view: MTKView) {

        update(view: view as! EIView, drawableSize: view.bounds.size)

        guard let buffer = commandQueue!.makeCommandBuffer() else {
            fatalError("Error: Can not create command buffer")
        }

        
        
        
        // ::::::::::::::::::::::::::::: begin ping pass :::::::::::::::::::::::::::::
        guard let renderToTextureEncoder = buffer.makeRenderCommandEncoder(descriptor: renderToTextureRenderPassDescriptor) else {
            fatalError("Error: Can not create command encoder")
        }

        // configure encoder
        renderToTextureEncoder.setFrontFacing(.counterClockwise)
        renderToTextureEncoder.setTriangleFillMode(.fill)
        renderToTextureEncoder.setCullMode(.none)
        renderToTextureEncoder.setFragmentSamplerState(samplerState, index: 0)

        // camerPlane encode
        cameraPlane.encode(encoder: renderToTextureEncoder)

        // model encode
        model.encode(encoder: renderToTextureEncoder)

        renderToTextureEncoder.endEncoding()
        // ::::::::::::::::::::::::::::: end ping pass :::::::::::::::::::::::::::::
        
        
        
        
        
        
        // ::::::::::::::::::::::::::::: begin pong pass :::::::::::::::::::::::::::::
        guard let descriptor = view.currentRenderPassDescriptor else {
            fatalError("Error: Can not create command buffer")
        }

        guard let drawable = view.currentDrawable else {
            fatalError("Error: Can not create command buffer")
        }

        descriptor.colorAttachments[ 0 ].clearColor = MTLClearColorMake(1, 1, 1, 1)
        
        guard let encoder = buffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            fatalError("Error: Can not create command encoder")
        }
        
        encoder.setFrontFacing(.counterClockwise)
        encoder.setTriangleFillMode(.fill)
        encoder.setCullMode(.none)
        encoder.setFragmentSamplerState(samplerState, index: 0)
        
        let textures:[MTLTexture] =
            [
                renderToTextureRenderPassDescriptor.colorAttachments[ 0 ].resolveTexture!,
                finalPassModel.shader.textures[ 0 ]
        ]
        
        // finalPassModel encode
        finalPassModel.renderPassEncode(encoder: encoder, textures: textures)
        
        encoder.endEncoding()
        // ::::::::::::::::::::::::::::: end pong pass :::::::::::::::::::::::::::::
        
        
        
        
        
        buffer.present(drawable)
        buffer.commit()

    }

}
