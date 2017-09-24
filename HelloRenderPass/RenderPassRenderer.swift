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

    var camera: EICamera

    // hero model
    var heroModel: EIQuad
    var heroModelTexture: MTLTexture
    var heroModelPipelineState: MTLRenderPipelineState!

    // hero backdrop
    var heroBackdrop: EIQuad
    var heroBackdropTexture: MTLTexture
    var heroBackdropPipelineState: MTLRenderPipelineState!

    // render to texture
    var renderToTexturePassDescriptor: MTLRenderPassDescriptor

    // final pass
    var finalPassRenderSurface: EIQuad
    var finalPassPipelineState: MTLRenderPipelineState!
    var finalPassTexture: MTLTexture

    var commandQueue: MTLCommandQueue!

    init(view: MTKView, device: MTLDevice) {

        let library = device.newDefaultLibrary()

        camera = EICamera(location:GLKVector3(v:(0, 0, 1000)), target:GLKVector3(v:(0, 0, 0)), approximateUp:GLKVector3(v:(0, 1, 0)))

        // hero model
        heroModel = EIQuad(device: device)

        do {
            heroModelTexture = try makeTexture(device: device, name: "kids_grid_3x3")
        } catch {
            fatalError("Error: Can not load texture")
        }

        do {

            let desc = MTLRenderPipelineDescriptor(view:view, library:library!, vertexShaderName:"textureVertexShader", fragmentShaderName:"textureFragmentShader", doIncludeDepthAttachment: true, vertexDescriptor: nil)
            desc.depthAttachmentPixelFormat = .depth32Float

            heroModelPipelineState = try device.makeRenderPipelineState(descriptor: desc)

        } catch let e {
            Swift.print("\(e)")
        }

        // hero backdrop
        heroBackdrop = EIQuad(device: device)

        do {
            heroBackdropTexture = try makeTexture(device: device, name: "mobile")
        } catch {
            fatalError("Error: Can not load texture")
        }

        do {

            let desc = MTLRenderPipelineDescriptor(view:view, library:library!, vertexShaderName:"textureVertexShader", fragmentShaderName:"textureFragmentShader", doIncludeDepthAttachment: true, vertexDescriptor: nil)
            desc.depthAttachmentPixelFormat = .depth32Float

            heroBackdropPipelineState = try device.makeRenderPipelineState(descriptor: desc)

        } catch let e {
            Swift.print("\(e)")
        }

        renderToTexturePassDescriptor = MTLRenderPassDescriptor(clearColor:MTLClearColorMake(1, 1, 1, 1), clearDepth:1)

        // final pass
        finalPassRenderSurface = EIQuad(device: device)

        do {
            finalPassTexture = try makeTexture(device: device, name: "mobile-overlay")
        } catch {
            fatalError("Error: Can not load texture")
        }


        do {

            let desc = MTLRenderPipelineDescriptor(view:view, library:library!, vertexShaderName:"finalPassVertexShader", fragmentShaderName:"finalPassOverlayFragmentShader", doIncludeDepthAttachment: false, vertexDescriptor: nil)
            desc.depthAttachmentPixelFormat = .depth32Float
            
            finalPassPipelineState = try device.makeRenderPipelineState(descriptor: desc)

        } catch let e {
            Swift.print("\(e)")
        }

        commandQueue = device.makeCommandQueue()

    }

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        reshape(view:view as! RenderPassMetalView)
    }

    func reshape (view: RenderPassMetalView) {

        view.arcBall.reshape(viewBounds: view.bounds)

        camera.setProjection(fovYDegrees:Float(35), aspectRatioWidthOverHeight:Float(view.bounds.size.width/view.bounds.size.height), near:200, far: 8000)

        // color
        let rgbaTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat:view.colorPixelFormat, width:Int(view.bounds.size.width), height:Int(view.bounds.size.height), mipmapped:true)
        rgbaTextureDescriptor.usage = [.renderTarget, .shaderRead]

        // depth
        let depthTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat:.depth32Float, width:Int(view.bounds.size.width), height:Int(view.bounds.size.height), mipmapped:false)
        depthTextureDescriptor.usage = .renderTarget

        renderToTexturePassDescriptor.colorAttachments[ 0 ].texture = view.device?.makeTexture(descriptor:rgbaTextureDescriptor)
        renderToTexturePassDescriptor.depthAttachment.texture       = view.device?.makeTexture(descriptor:depthTextureDescriptor)
    }

    func update(view: RenderPassMetalView, drawableSize:CGSize) {

        // render plane
        finalPassRenderSurface.metallicTransform.update(camera: camera, transformer: {
            return camera.createRenderPlaneTransform(distanceFromCamera: 0.75 * camera.far)
        })

        // hero model
        heroModel.metallicTransform.update(camera: camera, transformer: {
            return view.arcBall.rotationMatrix * GLKMatrix4MakeScale(150, 150, 1)
        })

        // hero backdrop
        heroBackdrop.metallicTransform.update(camera: camera, transformer: {
            return camera.createRenderPlaneTransform(distanceFromCamera: 0.35 * camera.far)
        })

    }

    public func draw(in view: MTKView) {

        update(view: view as! RenderPassMetalView, drawableSize: view.bounds.size)

        let commandBuffer = commandQueue.makeCommandBuffer()


        // render to texture
        let renderToTextureCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderToTexturePassDescriptor)

        renderToTextureCommandEncoder.setFrontFacing(.counterClockwise)
        renderToTextureCommandEncoder.setTriangleFillMode(.fill)
        renderToTextureCommandEncoder.setCullMode(.none)

        // hero backdrop
        renderToTextureCommandEncoder.setRenderPipelineState(heroBackdropPipelineState)

        renderToTextureCommandEncoder.setVertexBuffer(heroBackdrop.vertexMetalBuffer, offset: 0, at: 0)
        renderToTextureCommandEncoder.setVertexBuffer(heroBackdrop.metallicTransform.metalBuffer, offset: 0, at: 1)
        renderToTextureCommandEncoder.setFragmentTexture(heroBackdropTexture, at: 0)
        renderToTextureCommandEncoder.drawIndexedPrimitives(
                type: .triangle,
                indexCount: heroBackdrop.vertexIndexMetalBuffer.length / MemoryLayout<UInt16>.size,
                indexType: MTLIndexType.uint16,
                indexBuffer: heroBackdrop.vertexIndexMetalBuffer,
                indexBufferOffset: 0)

        // hero model
        renderToTextureCommandEncoder.setRenderPipelineState(heroModelPipelineState)

        renderToTextureCommandEncoder.setVertexBuffer(heroModel.vertexMetalBuffer, offset: 0, at: 0)
        renderToTextureCommandEncoder.setVertexBuffer(heroModel.metallicTransform.metalBuffer, offset: 0, at: 1)
        renderToTextureCommandEncoder.setFragmentTexture(heroModelTexture, at: 0)
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

            finalPassCommandEncoder.setVertexBuffer(finalPassRenderSurface.vertexMetalBuffer, offset: 0, at:0)
            finalPassCommandEncoder.setVertexBuffer(finalPassRenderSurface.metallicTransform.metalBuffer, offset: 0, at:1)
        
            finalPassCommandEncoder.setFragmentTexture(renderToTexturePassDescriptor.colorAttachments[ 0 ].texture, at:0)
            finalPassCommandEncoder.setFragmentTexture(finalPassTexture, at:1)

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
