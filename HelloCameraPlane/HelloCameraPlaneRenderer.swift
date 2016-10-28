//
//  RenderPassRenderer.swift
//  HelloMetal
//
//  Created by Douglass Turner on 9/11/16.
//  Copyright © 2016 Elastic Image Software. All rights reserved.
//

import MetalKit
import GLKit

class HelloCameraPlaneRenderer: NSObject, MTKViewDelegate {

    var camera: EICamera!

    // hero model
    var heroModel: MetallicQuadModel!
    var heroModelTexture: MTLTexture!
    var heroModelPipelineState: MTLRenderPipelineState!

    var cameraPlane: MetallicQuadModel!
    var cameraPlaneTexture: MTLTexture!
    var cameraPlanePipelineState: MTLRenderPipelineState!

    var commandQueue: MTLCommandQueue!

    init(view: MTKView, device: MTLDevice) {

        let library = device.newDefaultLibrary()
        
        camera = EICamera(location:GLKVector3(v:(0, 0, 1000)), target:GLKVector3(v:(0, 0, 0)), approximateUp:GLKVector3(v:(0, 1, 0)))

        
        // hero model
        heroModel = MetallicQuadModel(device: device)

        do {
            heroModelTexture = try makeTexture(device: device, name: "kids_grid_3x3")
        } catch {
            fatalError("Error: Can not load texture")
        }

        do {
            
            heroModelPipelineState =
                try device.makeRenderPipelineState(descriptor:
                    MTLRenderPipelineDescriptor(view:view,
                                                library:library!,
                                                vertexShaderName:"textureVertexShader",
                                                fragmentShaderName:"textureFragmentShader",
                                                doIncludeDepthAttachment: false,
                                                vertexDescriptor: nil))
        } catch let e {
            Swift.print("\(e)")
        }


        // render plane
        cameraPlane = MetallicQuadModel(device: device)

        do {
            cameraPlaneTexture = try makeTexture(device: device, name: "swirl")
        } catch {
            fatalError("Error: Can not load texture")
        }
        
        do {
            
            cameraPlanePipelineState =
                try device.makeRenderPipelineState(descriptor:
                    MTLRenderPipelineDescriptor(view:view,
                                                library:library!,
                                                vertexShaderName:"textureVertexShader",
                                                fragmentShaderName:"textureFragmentShader",
                                                doIncludeDepthAttachment: false,
                                                vertexDescriptor: nil))
            
        } catch let e {
            Swift.print("\(e)")
        }
        
        commandQueue = device.makeCommandQueue()

    }

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        reshape(view:view as! HelloCameraPlaneMetalView)
    }

    func reshape (view: HelloCameraPlaneMetalView) {
        view.arcBall.reshape(viewBounds: view.bounds)
        camera.setProjection(fovYDegrees:Float(35), aspectRatioWidthOverHeight:Float(view.bounds.size.width / view.bounds.size.height), near: 200, far: 8000)
    }

    func update(view: HelloCameraPlaneMetalView, drawableSize:CGSize) {

        // render plane
        cameraPlane.metallicTransform.update(camera: camera, transformer: {
            return camera.createRenderPlaneTransform(distanceFromCamera: 0.75 * camera.far)
        })

        // hero model
        heroModel.metallicTransform.update(camera: camera, transformer: {
            return view.arcBall.rotationMatrix * GLKMatrix4MakeScale(150, 150, 1)
        })
        
    }

    public func draw(in view: MTKView) {

        update(view: view as! HelloCameraPlaneMetalView, drawableSize: view.bounds.size)

        // final pass
        if let finalPassDescriptor = view.currentRenderPassDescriptor, let drawable = view.currentDrawable {

            let commandBuffer = commandQueue.makeCommandBuffer()
            
            let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: finalPassDescriptor)
            renderCommandEncoder.setFrontFacing(.counterClockwise)
            renderCommandEncoder.setTriangleFillMode(.fill)
            renderCommandEncoder.setCullMode(.none)

            // render plane
            renderCommandEncoder.setRenderPipelineState(cameraPlanePipelineState)
            renderCommandEncoder.setVertexBuffer(cameraPlane.vertexMetalBuffer, offset: 0, at: 0)
            renderCommandEncoder.setVertexBuffer(cameraPlane.metallicTransform.metalBuffer, offset: 0, at: 1)
            renderCommandEncoder.setFragmentTexture(cameraPlaneTexture, at: 0)
            renderCommandEncoder.drawIndexedPrimitives(
                    type: .triangle,
                    indexCount: cameraPlane.vertexIndexMetalBuffer.length / MemoryLayout<UInt16>.size,
                    indexType: MTLIndexType.uint16,
                    indexBuffer: cameraPlane.vertexIndexMetalBuffer,
                    indexBufferOffset: 0)

            // hero model
            renderCommandEncoder.setRenderPipelineState(heroModelPipelineState)
            renderCommandEncoder.setVertexBuffer(heroModel.vertexMetalBuffer, offset: 0, at: 0)
            renderCommandEncoder.setVertexBuffer(heroModel.metallicTransform.metalBuffer, offset: 0, at: 1)
            renderCommandEncoder.setFragmentTexture(heroModelTexture, at: 0)
            renderCommandEncoder.drawIndexedPrimitives(
                    type: .triangle,
                    indexCount: heroModel.vertexIndexMetalBuffer.length / MemoryLayout<UInt16>.size,
                    indexType: MTLIndexType.uint16,
                    indexBuffer: heroModel.vertexIndexMetalBuffer,
                    indexBufferOffset: 0)

            renderCommandEncoder.endEncoding()



            commandBuffer.present(drawable)
            commandBuffer.commit()
        }

    }

}
