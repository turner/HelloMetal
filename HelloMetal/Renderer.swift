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

    var camera: EISCamera!

    var heroModel: MetallicQuadModel!
    var heroTexture: MTLTexture!

    var renderToTexturePassDescriptor: MTLRenderPassDescriptor!
    var renderToTexturePipelineState: MTLRenderPipelineState!

    var finalPassRenderSurface: MetallicQuadModel!
    var finalPassPipelineState: MTLRenderPipelineState!

    var commandQueue: MTLCommandQueue!

    init(view: MTKView, device: MTLDevice) {

//        view.sampleCount = 4

        camera = EISCamera(location:GLKVector3(v:(0, 0, 1000)), target:GLKVector3(v:(0, 0, 0)), approximateUp:GLKVector3(v:(0, 1, 0)))

        heroModel = MetallicQuadModel(device: device)

        // load hero texture
        do {

            let textureLoader = MTKTextureLoader(device: device)

            guard let image = UIImage(named:"red_translucent") else {
                fatalError("Error: Can not create UIImage")
            }

            if (image.cgImage?.alphaInfo == .premultipliedLast) {
                print("texture uses premultiplied alpha. Rock.")
            }
            
            heroTexture = try textureLoader.newTexture(with: image.cgImage!, options: nil)
        } catch {
            fatalError("Error: Can not load texture")
        }

        let library = device.newDefaultLibrary()

        // render to texture
        do {

            let renderToTexturePipelineDescriptor = MTLRenderPipelineDescriptor()

            renderToTexturePipelineDescriptor.vertexFunction = library?.makeFunction(name: "textureVertexShader")!
            renderToTexturePipelineDescriptor.fragmentFunction = library?.makeFunction(name: "textureFragmentShader")!

            renderToTexturePipelineDescriptor.colorAttachments[ 0 ].pixelFormat = view.colorPixelFormat
            
            renderToTexturePipelineDescriptor.colorAttachments[ 0 ].isBlendingEnabled = true
            
            renderToTexturePipelineDescriptor.colorAttachments[ 0 ].rgbBlendOperation = .add
            renderToTexturePipelineDescriptor.colorAttachments[ 0 ].alphaBlendOperation = .add
            
            renderToTexturePipelineDescriptor.colorAttachments[ 0 ].sourceRGBBlendFactor = .one
            renderToTexturePipelineDescriptor.colorAttachments[ 0 ].sourceAlphaBlendFactor = .one

            renderToTexturePipelineDescriptor.colorAttachments[ 0 ].destinationRGBBlendFactor = .oneMinusSourceAlpha
            renderToTexturePipelineDescriptor.colorAttachments[ 0 ].destinationAlphaBlendFactor = .oneMinusSourceAlpha

            renderToTexturePipelineDescriptor.depthAttachmentPixelFormat = .depth32Float

            renderToTexturePipelineState = try device.makeRenderPipelineState(descriptor: renderToTexturePipelineDescriptor)
        } catch let e {
            Swift.print("\(e)")
        }

        renderToTexturePassDescriptor = MTLRenderPassDescriptor()

        // color
        renderToTexturePassDescriptor.colorAttachments[ 0 ] = MTLRenderPassColorAttachmentDescriptor()
        renderToTexturePassDescriptor.colorAttachments[ 0 ].storeAction = .store
        renderToTexturePassDescriptor.colorAttachments[ 0 ].loadAction = .clear
        renderToTexturePassDescriptor.colorAttachments[ 0 ].clearColor = MTLClearColorMake(1, 1, 1, 1)

        // depth
        renderToTexturePassDescriptor.depthAttachment = MTLRenderPassDepthAttachmentDescriptor()
        renderToTexturePassDescriptor.depthAttachment.storeAction = .dontCare
        renderToTexturePassDescriptor.depthAttachment.loadAction = .clear
        renderToTexturePassDescriptor.depthAttachment.clearDepth = 1.0;


        // final pass

        finalPassRenderSurface = MetallicQuadModel(device: device)

        do {

            let finalPassPipelineDescriptor = MTLRenderPipelineDescriptor()

            finalPassPipelineDescriptor.vertexFunction = library?.makeFunction(name: "finalPassVertexShader")!
            finalPassPipelineDescriptor.fragmentFunction = library?.makeFunction(name: "finalPassFragmentShader")!

            finalPassPipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat

            finalPassPipelineDescriptor.colorAttachments[ 0 ].isBlendingEnabled = true

            finalPassPipelineDescriptor.colorAttachments[ 0 ].rgbBlendOperation = .add
            finalPassPipelineDescriptor.colorAttachments[ 0 ].alphaBlendOperation = .add

            finalPassPipelineDescriptor.colorAttachments[ 0 ].sourceRGBBlendFactor = .one
            finalPassPipelineDescriptor.colorAttachments[ 0 ].sourceAlphaBlendFactor = .one

            finalPassPipelineDescriptor.colorAttachments[ 0 ].destinationRGBBlendFactor = .oneMinusSourceAlpha
            finalPassPipelineDescriptor.colorAttachments[ 0 ].destinationAlphaBlendFactor = .oneMinusSourceAlpha

            finalPassPipelineState = try device.makeRenderPipelineState(descriptor: finalPassPipelineDescriptor)
        } catch let e {
            Swift.print("\(e)")
        }

        commandQueue = device.makeCommandQueue()

    }

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        reshape(view:view as! MetalView)
    }

    func reshape (view: MetalView) {

        view.arcBall.reshape(viewBounds: view.bounds)

        camera.setProjection(fovYDegrees:Float(35), aspectRatioWidthOverHeight:Float(view.bounds.size.width / view.bounds.size.height), near: 200, far: 8000)

        // color
        let rgbaTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: view.colorPixelFormat, width: Int(view.bounds.size.width), height: Int(view.bounds.size.height), mipmapped: true)
        renderToTexturePassDescriptor.colorAttachments[ 0 ].texture = view.device?.makeTexture(descriptor: rgbaTextureDescriptor)

        // depth
        let depthTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .depth32Float, width: Int(view.bounds.size.width), height: Int(view.bounds.size.height), mipmapped: false)
        renderToTexturePassDescriptor.depthAttachment.texture = view.device?.makeTexture(descriptor: depthTextureDescriptor)

    }

    func update(view: MetalView, drawableSize:CGSize) {

        let fudge = 0.35 * camera.far
        let dimension = fudge * tan( GLKMathDegreesToRadians( camera.fovYDegrees/2 ) )

        let scale = GLKMatrix4MakeScale(camera.aspectRatioWidthOverHeight * dimension, dimension, 1)

        // render plane
        finalPassRenderSurface.metallicTransform.transform.modelMatrix = camera.createRenderPlaneTransform(distanceFromCamera: fudge) * scale
        finalPassRenderSurface.metallicTransform.transform.modelViewProjectionMatrix = camera.projectionTransform * camera.transform * finalPassRenderSurface.metallicTransform.transform.modelMatrix
        finalPassRenderSurface.metallicTransform.update()


        // hero model
        heroModel.metallicTransform.transform.modelMatrix = view.arcBall.rotationMatrix * GLKMatrix4MakeScale(120, 240, 1)
        heroModel.metallicTransform.transform.modelViewProjectionMatrix = camera.projectionTransform * camera.transform * heroModel.metallicTransform.transform.modelMatrix
        heroModel.metallicTransform.update()

    }

    public func draw(in view: MTKView) {

        update(view: view as! MetalView, drawableSize: view.bounds.size)

        let commandBuffer = commandQueue.makeCommandBuffer()


        // render to texture
        let renderToTextureCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderToTexturePassDescriptor)
        renderToTextureCommandEncoder.setRenderPipelineState(renderToTexturePipelineState)

        renderToTextureCommandEncoder.setFrontFacing(.counterClockwise)
        renderToTextureCommandEncoder.setTriangleFillMode(.fill)
        renderToTextureCommandEncoder.setCullMode(.none)

        renderToTextureCommandEncoder.setVertexBuffer(heroModel.vertexMetalBuffer, offset: 0, at: 0)
        renderToTextureCommandEncoder.setVertexBuffer(heroModel.metallicTransform.metalBuffer, offset: 0, at: 1)

        renderToTextureCommandEncoder.setFragmentTexture(heroTexture, at: 0)

        renderToTextureCommandEncoder.drawIndexedPrimitives(
                type: .triangle,
                indexCount: heroModel.vertexIndexMetalBuffer.length / MemoryLayout<UInt16>.size,
                indexType: MTLIndexType.uint16,
                indexBuffer: heroModel.vertexIndexMetalBuffer,
                indexBufferOffset: 0)

        renderToTextureCommandEncoder.endEncoding()

        // final pass
        if let finalPassDescriptor = view.currentRenderPassDescriptor, let drawable = view.currentDrawable {

            finalPassDescriptor.colorAttachments[ 0 ].clearColor = MTLClearColorMake(1, 1, 1, 1)

            let finalPassCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: finalPassDescriptor)
            finalPassCommandEncoder.setRenderPipelineState(finalPassPipelineState)

            finalPassCommandEncoder.setFrontFacing(.counterClockwise)
            finalPassCommandEncoder.setTriangleFillMode(.fill)
            finalPassCommandEncoder.setCullMode(.none)

            finalPassCommandEncoder.setVertexBuffer(finalPassRenderSurface.vertexMetalBuffer, offset: 0, at: 0)
            finalPassCommandEncoder.setVertexBuffer(finalPassRenderSurface.metallicTransform.metalBuffer, offset: 0, at: 1)

            finalPassCommandEncoder.setFragmentTexture(renderToTexturePassDescriptor.colorAttachments[ 0 ].texture, at: 0)

            finalPassCommandEncoder.drawIndexedPrimitives(
                    type: .triangle,
                    indexCount: finalPassRenderSurface.vertexIndexMetalBuffer.length / MemoryLayout<UInt16>.size,
                    indexType: MTLIndexType.uint16,
                    indexBuffer: finalPassRenderSurface.vertexIndexMetalBuffer,
                    indexBufferOffset: 0)

            finalPassCommandEncoder.endEncoding()


            commandBuffer.present(drawable)
            commandBuffer.commit()
        }

    }

}
