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
    
    let depthStencilState: MTLDepthStencilState?
    let samplerState: MTLSamplerState?
    let commandQueue: MTLCommandQueue?

    init(view: MTKView, device: MTLDevice) {

        guard let ss = MTLSamplerDescriptor.EI_CreateMipMapSamplerState(device: device) else {
            fatalError("Error: Can not create sampler state")
        }
        
        samplerState = ss
        
        guard let cq = device.makeCommandQueue() else {
            fatalError("Error: Can not create command queue")
        }
        
        commandQueue = cq

        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = true
        
        guard let dss = device.makeDepthStencilState(descriptor: depthStencilDescriptor) else {
            fatalError("Error: Can not create depth stencil state")
        }
        
        depthStencilState = dss
    }

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        reshape(view:view as! EIView)
    }

    func reshape (view: EIView) {
        view.arcBall.reshape(viewBounds: view.bounds)
        camera.setProjection(fovYDegrees:Float(35), aspectRatioWidthOverHeight:Float(view.bounds.size.width / view.bounds.size.height), near: 200, far: 8000)
    }

    func update(view: EIView, drawableSize:CGSize) {

        // camera plane
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

            // camera plane
            encoder.EI_ConfigureWithEIMesh(renderPipelineState: cameraPlanePipelineState, model: cameraPlane, textures: [cameraPlaneTexture])

            // hero model
            encoder.EI_ConfigureWithEIMesh(renderPipelineState: pipelineState, model: self.model, textures: [texture])

            encoder.endEncoding()

            buffer.present(drawable)
            buffer.commit()
        }

    }
}
