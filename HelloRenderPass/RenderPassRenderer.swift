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
        let pingDescriptor = renderToTextureRenderPassDescriptor
        guard let pingEncoder = buffer.makeRenderCommandEncoder(descriptor: pingDescriptor) else {
            fatalError("Error: Can not create command encoder")
        }

        // configure encoder
        pingEncoder.setFrontFacing(.counterClockwise)
        pingEncoder.setTriangleFillMode(.fill)
        pingEncoder.setCullMode(.none)
        pingEncoder.setFragmentSamplerState(samplerState, index: 0)

        // camerPlane encode
        cameraPlane.encode(encoder: pingEncoder)

        // model encode
        model.encode(encoder: pingEncoder)

        pingEncoder.endEncoding()
        // ::::::::::::::::::::::::::::: end ping pass :::::::::::::::::::::::::::::
        
        
        
        
        
        
        // ::::::::::::::::::::::::::::: begin pong pass :::::::::::::::::::::::::::::
        let pongDescriptor = view.currentRenderPassDescriptor!
        guard let pongEncoder = buffer.makeRenderCommandEncoder(descriptor: pongDescriptor) else {
            fatalError("Error: Can not create command encoder")
        }

        // configure encoder
        pongEncoder.setFrontFacing(.counterClockwise)
        pongEncoder.setTriangleFillMode(.fill)
        pongEncoder.setCullMode(.none)
        pongEncoder.setFragmentSamplerState(samplerState, index: 0)

        // texture(0) is the render-to-texture results
        // texture(1) is a cool effect to show off compositing
        let textures:[MTLTexture] =
            [
                pingDescriptor.colorAttachments[ 0 ].resolveTexture!,
                finalPassModel.shader.textures[ 0 ]
        ]
        
        // finalPassModel encode - This surface is texture mapped with the render-to-texture texture of the "ping" pass
        finalPassModel.renderPassEncode(encoder: pongEncoder, textures: textures)
        
        pongEncoder.endEncoding()
        // ::::::::::::::::::::::::::::: end pong pass :::::::::::::::::::::::::::::
        
        
        guard let drawable = view.currentDrawable else {
            fatalError("Error: Can not create command buffer")
        }

        buffer.present(drawable)
        buffer.commit()

    }

}
