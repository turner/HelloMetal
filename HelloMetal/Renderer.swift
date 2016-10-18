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

    var renderPlane: MetallicQuadModel!
    var heroModel: MetallicQuadModel!

    var camera: EISCamera!

    var renderToTexturePassDescriptor: MTLRenderPassDescriptor!
    var renderToTexturePipelineState: MTLRenderPipelineState!

    var finalPassPipelineState: MTLRenderPipelineState!

    var depthStencilState: MTLDepthStencilState!
    var commandQueue: MTLCommandQueue!
    var heroTexture: MTLTexture!

    init(view: MTKView, device: MTLDevice) {

        renderPlane = MetallicQuadModel(device: device)
        heroModel = MetallicQuadModel(device: device)

        camera = EISCamera()
        // viewing frustrum - eye looks along z-axis towards -z direction
        //                    +y up
        //                    +x to the right

        camera.setTransform(location:GLKVector3(v:(0, 0, 1000)), target:GLKVector3(v:(0, 0, 0)), approximateUp:GLKVector3(v:(0, 1, 0)))

        guard let image = UIImage(named:"diagnostic") else {
            fatalError("Error: Can not create image")
        }
        
        let textureLoader = MTKTextureLoader(device: device)
        
        do {
            heroTexture = try textureLoader.newTexture(with: image.cgImage!, options: nil)
        } catch {
            fatalError("Error: Can not load texture")
        }
        
        let library = device.newDefaultLibrary()

        let renderToTexturePipelineDescriptor = MTLRenderPipelineDescriptor()
        renderToTexturePipelineDescriptor.vertexFunction = library?.makeFunction(name: "helloTextureVertexShader")!
        renderToTexturePipelineDescriptor.fragmentFunction = library?.makeFunction(name: "helloTextureFragmentShader")!
        renderToTexturePipelineDescriptor.colorAttachments[ 0 ].pixelFormat = view.colorPixelFormat
        renderToTexturePipelineDescriptor.depthAttachmentPixelFormat = .depth32Float

        do {
            renderToTexturePipelineState = try device.makeRenderPipelineState(descriptor: renderToTexturePipelineDescriptor)
        } catch let e {
            Swift.print("\(e)")
        }

        renderToTexturePassDescriptor = MTLRenderPassDescriptor()

        // color
        renderToTexturePassDescriptor.colorAttachments[ 0 ] = MTLRenderPassColorAttachmentDescriptor()
        let rgbaTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: view.colorPixelFormat, width: Int(view.bounds.size.width), height: Int(view.bounds.size.height), mipmapped: false)
        renderToTexturePassDescriptor.colorAttachments[ 0 ].texture = device.makeTexture(descriptor: rgbaTextureDescriptor)

        renderToTexturePassDescriptor.colorAttachments[ 0 ].storeAction = .store
        renderToTexturePassDescriptor.colorAttachments[ 0 ].loadAction = .clear
        renderToTexturePassDescriptor.colorAttachments[ 0 ].clearColor = MTLClearColorMake(0.3, 0.5, 0.5, 1.0)

        // depth
        renderToTexturePassDescriptor.depthAttachment = MTLRenderPassDepthAttachmentDescriptor()
        let depthTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .depth32Float, width: Int(view.bounds.size.width), height: Int(view.bounds.size.height), mipmapped: false)
        renderToTexturePassDescriptor.depthAttachment.texture = device.makeTexture(descriptor: depthTextureDescriptor)
        renderToTexturePassDescriptor.depthAttachment.storeAction = .store
        renderToTexturePassDescriptor.depthAttachment.loadAction = .clear
        renderToTexturePassDescriptor.depthAttachment.clearDepth = 1.0;



        let finalPassPipelineDescriptor = MTLRenderPipelineDescriptor()
        finalPassPipelineDescriptor.vertexFunction = library?.makeFunction(name: "finalPassVertexShader")!
        finalPassPipelineDescriptor.fragmentFunction = library?.makeFunction(name: "finalPassFragmentShader")!
        finalPassPipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat

        do {
            finalPassPipelineState = try device.makeRenderPipelineState(descriptor: finalPassPipelineDescriptor)
        } catch let e {
            Swift.print("\(e)")
        }






        commandQueue = device.makeCommandQueue()

    }

    func update(view: MetalView, drawableSize:CGSize) {

        let fudge = 0.9 * camera.far
        let dimension = fudge * tan( GLKMathDegreesToRadians( camera.fovYDegrees/2 ) )
        
        let scale = GLKMatrix4MakeScale(camera.aspectRatioWidthOverHeight * dimension, dimension, 1)
        
        // render plane
        renderPlane.transform.transforms.modelMatrix = camera.createRenderPlaneTransform(distanceFromCamera: fudge) * scale
        renderPlane.transform.transforms.modelViewProjectionMatrix = camera.projectionTransform * camera.transform * renderPlane.transform.transforms.modelMatrix
        renderPlane.transform.update()


        // hero model
        heroModel.transform.transforms.modelMatrix = view.arcBall.rotationMatrix * GLKMatrix4MakeScale(100, 200, 1)
        heroModel.transform.transforms.modelViewProjectionMatrix = camera.projectionTransform * camera.transform * heroModel.transform.transforms.modelMatrix
        heroModel.transform.update()

    }

    func reshape (view: MetalView) {
        view.arcBall.reshape(viewBounds: view.bounds)
        camera.setProjection(fovYDegrees:Float(35), aspectRatioWidthOverHeight:Float(view.bounds.size.width / view.bounds.size.height), near: 200, far: 2000)
    }

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        reshape(view:view as! MetalView)
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
        renderToTextureCommandEncoder.setVertexBuffer(heroModel.transform.metalBuffer, offset: 0, at: 1)

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

            let finalPassCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: finalPassDescriptor)

            finalPassCommandEncoder.setRenderPipelineState(finalPassPipelineState)

            finalPassCommandEncoder.setFrontFacing(.counterClockwise)
            finalPassCommandEncoder.setTriangleFillMode(.fill)
            finalPassCommandEncoder.setCullMode(.none)

            finalPassCommandEncoder.setVertexBuffer(renderPlane.vertexMetalBuffer, offset: 0, at: 0)
            finalPassCommandEncoder.setVertexBuffer(renderPlane.transform.metalBuffer, offset: 0, at: 1)

            finalPassCommandEncoder.setFragmentTexture(renderToTexturePassDescriptor.colorAttachments[ 0 ].texture, at: 0)

            finalPassCommandEncoder.drawIndexedPrimitives(
                    type: .triangle,
                    indexCount: renderPlane.vertexIndexMetalBuffer.length / MemoryLayout<UInt16>.size,
                    indexType: MTLIndexType.uint16,
                    indexBuffer: renderPlane.vertexIndexMetalBuffer,
                    indexBufferOffset: 0)

            finalPassCommandEncoder.endEncoding()


            commandBuffer.present(drawable)
            commandBuffer.commit()
        }

    }

}
