//
//  RenderPassRenderer.swift
//  HelloMetal
//
//  Created by Douglass Turner on 9/11/16.
//  Copyright © 2016 Elastic Image Software. All rights reserved.
//
import ModelIO
import MetalKit
import GLKit

class Model_IORenderer: NSObject, MTKViewDelegate {

    var camera: EICamera!

    // hero model
    var model: EIMesh!
    var texture: MTLTexture!
    var pipelineState: MTLRenderPipelineState!

    var frontTexture: MTLTexture!
    var backTexture: MTLTexture!

    var cameraPlane: EIMesh!
    var cameraPlaneTexture: MTLTexture!
    var cameraPlanePipelineState: MTLRenderPipelineState!
    
    var depthStencilState: MTLDepthStencilState

    let samplerState: MTLSamplerState?
    let commandQueue: MTLCommandQueue?

    init(view: MTKView, device: MTLDevice) {

        guard let library = device.makeDefaultLibrary() else {
            fatalError("Error: Can not create default library")
        }

//        heroModel = EIMesh.sphere(device: device, xRadius: 150, yRadius: 150, zRadius: 150, uTesselation: 32, vTesselation: 32)
        model = EIMesh.cube(device: device, xExtent: 200, yExtent: 100, zExtent: 200, xTesselation: 32, yTesselation: 32, zTesselation: 32)
//        heroModel = EIMesh.plane(device: device, xExtent: 200, zExtent: 200, xTesselation: 2, zTesselation: 2)

        do {
            texture = try makeTexture(device: device, name: "mandrill")
        } catch {
            fatalError("Error: Can not load texture")
        }

        do {
            frontTexture = try makeTexture(device: device, name: "mandrill")
        } catch {
            fatalError("Error: Can not load texture")
        }

        do {
            backTexture = try makeTexture(device: device, name: "lena")
        } catch {
            fatalError("Error: Can not load texture")
        }

        do {

            // vertexShaderName:"litTextureMIOVertexShader",
            // fragmentShaderName:"litTextureMIOFragmentShader",

            let pipelineDescriptor =
                    MTLRenderPipelineDescriptor.EI_Create(library:library, vertexShaderName:"textureMIOVertexShader", fragmentShaderName:"textureMIOFragmentShader", sampleCount:view.sampleCount, colorPixelFormat:view.colorPixelFormat, vertexDescriptor: model.metalVertexDescriptor)

            pipelineState = try device.makeRenderPipelineState(descriptor:pipelineDescriptor)
        } catch let e {
            Swift.print("\(e)")
        }

        // render plane
        cameraPlane = EIMesh.plane(device: device, xExtent: 2, zExtent: 2, xTesselation: 4, zTesselation: 4)

        do {
            cameraPlaneTexture = try makeTexture(device: device, name: "mobile")
        } catch {
            fatalError("Error: Can not load texture")
        }

        do {

            let pipelineDescriptor =
                    MTLRenderPipelineDescriptor.EI_Create(library:library, vertexShaderName:"textureMIOVertexShader", fragmentShaderName:"textureMIOFragmentShader", sampleCount:view.sampleCount, colorPixelFormat:view.colorPixelFormat, vertexDescriptor: model.metalVertexDescriptor)

            cameraPlanePipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)

        } catch let e {
            Swift.print("\(e)")
        }








        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = true
        
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)!









        guard let ss = MTLSamplerDescriptor.EI_CreateMipMapSamplerState(device: device) else {
            fatalError("Error: Can not create sampler state")
        }

        samplerState = ss

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

        // render plane
        cameraPlane.metallicTransform.update(camera: camera, transformer: {
            return camera.createRenderPlaneTransform(distanceFromCamera: 0.75 * camera.far) * GLKMatrix4MakeRotation(GLKMathDegreesToRadians(90), 1, 0, 0)
        })

        // hero model
        model.metallicTransform.update(camera: camera, transformer: {
            return view.arcBall.rotationMatrix
        })

    }

    /*
    public func DEPRICATED_draw(in view: MTKView) {

        update(view: view as! Model_IOMetalView, drawableSize: view.bounds.size)

        // final pass
        if let finalPassDescriptor = view.currentRenderPassDescriptor, let drawable = view.currentDrawable {

            let commandBuffer = commandQueue.makeCommandBuffer()!

            let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: finalPassDescriptor)!
            
            renderCommandEncoder.setDepthStencilState(depthStencilState)
            
            renderCommandEncoder.setFrontFacing(.counterClockwise)
            renderCommandEncoder.setCullMode(.none)

            
            
            
            
            // render plane
            renderCommandEncoder.setTriangleFillMode(.fill)

            renderCommandEncoder.setRenderPipelineState(renderPlanePipelineState)

            renderCommandEncoder.setVertexBuffer(renderPlane.vertexMetalBuffer, offset: 0, index: 0)
            renderCommandEncoder.setVertexBuffer(renderPlane.metallicTransform.metalBuffer, offset: 0, index: 1)

            renderCommandEncoder.setFragmentTexture(renderPlaneTexture, index: 0)

            renderCommandEncoder.drawIndexedPrimitives(
                    type: renderPlane.primitiveType,
                    indexCount: renderPlane.indexCount,
                    indexType: renderPlane.indexType,
                    indexBuffer: renderPlane.vertexIndexMetalBuffer,
                    indexBufferOffset: 0)



            

            // hero model
            renderCommandEncoder.setTriangleFillMode(.fill)

            renderCommandEncoder.setRenderPipelineState(pipelineState)

            renderCommandEncoder.setVertexBuffer(model.vertexMetalBuffer, offset: 0, index: 0)
            renderCommandEncoder.setVertexBuffer(model.metallicTransform.metalBuffer, offset: 0, index: 1)

            renderCommandEncoder.setFragmentTexture(texture, index: 0)

            renderCommandEncoder.drawIndexedPrimitives(
                    type: model.primitiveType,
                    indexCount: model.indexCount,
                    indexType: model.indexType,
                    indexBuffer: model.vertexIndexMetalBuffer,
                    indexBufferOffset: 0)

            
            
            
            
            renderCommandEncoder.endEncoding()

            commandBuffer.present(drawable)
            commandBuffer.commit()
        }

    }
    */

    public func draw(in view: MTKView) {

        update(view: view as! EIView, drawableSize: view.bounds.size)

        if let passDescriptor = view.currentRenderPassDescriptor, let drawable = view.currentDrawable {

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

            // render plane
            encoder.EI_ConfigureWithEIMesh(renderPipelineState: cameraPlanePipelineState, model: cameraPlane, textures: [cameraPlaneTexture])

            // hero model
            encoder.EI_ConfigureWithEIMesh(renderPipelineState: pipelineState, model: self.model, textures: [texture])

            encoder.endEncoding()

            buffer.present(drawable)
            buffer.commit()
        }

    }
}
