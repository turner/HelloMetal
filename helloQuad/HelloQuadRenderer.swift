//
//  MultiPassRenderer.swift
//  HelloMetal
//
//  Created by Douglass Turner on 9/11/16.
//  Copyright © 2016 Elastic Image Software. All rights reserved.
//

import MetalKit
import GLKit

class HelloQuadRenderer: NSObject, MTKViewDelegate {

    var camera: EISCamera!

    // hero model
    var heroModel: MetallicQuadModel!
    var heroModelTexture: MTLTexture!
    var heroModelPipelineState: MTLRenderPipelineState!

    var renderPlane: MetallicQuadModel!
    var renderPlaneTexture: MTLTexture!
    var renderPlanePipelineState: MTLRenderPipelineState!

    var commandQueue: MTLCommandQueue!

    init(view: MTKView, device: MTLDevice) {

        let library = device.newDefaultLibrary()
        
        camera = EISCamera(location:GLKVector3(v:(0, 0, 1000)), target:GLKVector3(v:(0, 0, 0)), approximateUp:GLKVector3(v:(0, 1, 0)))

        
        // hero model
        heroModel = MetallicQuadModel(device: device)

        do {

            let textureLoader = MTKTextureLoader(device: device)

            guard let image = UIImage(named:"kids_grid_3x3") else {
                fatalError("Error: Can not create UIImage")
            }

            if (image.cgImage?.alphaInfo == .premultipliedLast) {
                print("texture uses premultiplied alpha. Rock.")
            }

            let textureLoaderOptions:[String:NSNumber] = [ MTKTextureLoaderOptionSRGB:false ]

            heroModelTexture = try textureLoader.newTexture(with: image.cgImage!, options: textureLoaderOptions)
        } catch {
            fatalError("Error: Can not load texture")
        }

        do {

            let heroModelPipelineDescriptor = MTLRenderPipelineDescriptor()

            heroModelPipelineDescriptor.vertexFunction = library?.makeFunction(name: "textureVertexShader")!
            heroModelPipelineDescriptor.fragmentFunction = library?.makeFunction(name: "textureFragmentShader")!

            heroModelPipelineDescriptor.colorAttachments[ 0 ].pixelFormat = view.colorPixelFormat
            
            heroModelPipelineDescriptor.colorAttachments[ 0 ].isBlendingEnabled = true
            
            heroModelPipelineDescriptor.colorAttachments[ 0 ].rgbBlendOperation = .add
            heroModelPipelineDescriptor.colorAttachments[ 0 ].alphaBlendOperation = .add
            
            heroModelPipelineDescriptor.colorAttachments[ 0 ].sourceRGBBlendFactor = .one
            heroModelPipelineDescriptor.colorAttachments[ 0 ].sourceAlphaBlendFactor = .one

            heroModelPipelineDescriptor.colorAttachments[ 0 ].destinationRGBBlendFactor = .oneMinusSourceAlpha
            heroModelPipelineDescriptor.colorAttachments[ 0 ].destinationAlphaBlendFactor = .oneMinusSourceAlpha

            heroModelPipelineState = try device.makeRenderPipelineState(descriptor: heroModelPipelineDescriptor)
        } catch let e {
            Swift.print("\(e)")
        }


        // render plane
        renderPlane = MetallicQuadModel(device: device)

        do {

            let textureLoader = MTKTextureLoader(device: device)

            guard let image = UIImage(named:"diagnostic") else {
                fatalError("Error: Can not create UIImage")
            }

            if (image.cgImage?.alphaInfo == .premultipliedLast) {
                print("texture uses premultiplied alpha. Rock.")
            }

            let textureLoaderOptions:[String:NSNumber] = [ MTKTextureLoaderOptionSRGB:false ]

            renderPlaneTexture = try textureLoader.newTexture(with: image.cgImage!, options: textureLoaderOptions)
        } catch {
            fatalError("Error: Can not load texture")
        }

        do {

            let renderPlanePipelineDescriptor = MTLRenderPipelineDescriptor()

            renderPlanePipelineDescriptor.vertexFunction = library?.makeFunction(name: "textureVertexShader")!
            renderPlanePipelineDescriptor.fragmentFunction = library?.makeFunction(name: "textureFragmentShader")!

            renderPlanePipelineDescriptor.colorAttachments[ 0 ].pixelFormat = view.colorPixelFormat

            renderPlanePipelineDescriptor.colorAttachments[ 0 ].isBlendingEnabled = true

            renderPlanePipelineDescriptor.colorAttachments[ 0 ].rgbBlendOperation = .add
            renderPlanePipelineDescriptor.colorAttachments[ 0 ].alphaBlendOperation = .add

            renderPlanePipelineDescriptor.colorAttachments[ 0 ].sourceRGBBlendFactor = .one
            renderPlanePipelineDescriptor.colorAttachments[ 0 ].sourceAlphaBlendFactor = .one

            renderPlanePipelineDescriptor.colorAttachments[ 0 ].destinationRGBBlendFactor = .oneMinusSourceAlpha
            renderPlanePipelineDescriptor.colorAttachments[ 0 ].destinationAlphaBlendFactor = .oneMinusSourceAlpha

            renderPlanePipelineState = try device.makeRenderPipelineState(descriptor: renderPlanePipelineDescriptor)
        } catch let e {
            Swift.print("\(e)")
        }
        
        commandQueue = device.makeCommandQueue()

    }

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        reshape(view:view as! HelloQuadMetalView)
    }

    func reshape (view: HelloQuadMetalView) {
        view.arcBall.reshape(viewBounds: view.bounds)
        camera.setProjection(fovYDegrees:Float(35), aspectRatioWidthOverHeight:Float(view.bounds.size.width / view.bounds.size.height), near: 200, far: 8000)
    }

    func update(view: HelloQuadMetalView, drawableSize:CGSize) {

        var fudge: Float
        var dimension: Float
        var scale: GLKMatrix4
        
        // render plane
        fudge = 0.75 * camera.far
        dimension = fudge * tan( GLKMathDegreesToRadians( camera.fovYDegrees/2 ) )
        scale = GLKMatrix4MakeScale(camera.aspectRatioWidthOverHeight * dimension, dimension, 1)
        renderPlane.metallicTransform.transform.modelMatrix = camera.createRenderPlaneTransform(distanceFromCamera: fudge) * scale
        renderPlane.metallicTransform.transform.modelViewProjectionMatrix = camera.projectionTransform * camera.transform * renderPlane.metallicTransform.transform.modelMatrix
        renderPlane.metallicTransform.update()

        // hero model
        heroModel.metallicTransform.transform.modelMatrix = view.arcBall.rotationMatrix * GLKMatrix4MakeScale(150, 150, 1)
        heroModel.metallicTransform.transform.modelViewProjectionMatrix = camera.projectionTransform * camera.transform * heroModel.metallicTransform.transform.modelMatrix
        heroModel.metallicTransform.update()

    }

    public func draw(in view: MTKView) {

        update(view: view as! HelloQuadMetalView, drawableSize: view.bounds.size)

        // final pass
        if let finalPassDescriptor = view.currentRenderPassDescriptor, let drawable = view.currentDrawable {

            let commandBuffer = commandQueue.makeCommandBuffer()
            
            let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: finalPassDescriptor)
            renderCommandEncoder.setFrontFacing(.counterClockwise)
            renderCommandEncoder.setTriangleFillMode(.fill)
            renderCommandEncoder.setCullMode(.none)

            // render plane
            renderCommandEncoder.setRenderPipelineState(renderPlanePipelineState)
            renderCommandEncoder.setVertexBuffer(renderPlane.vertexMetalBuffer, offset: 0, at: 0)
            renderCommandEncoder.setVertexBuffer(renderPlane.metallicTransform.metalBuffer, offset: 0, at: 1)
            renderCommandEncoder.setFragmentTexture(renderPlaneTexture, at: 0)
            renderCommandEncoder.drawIndexedPrimitives(
                    type: .triangle,
                    indexCount: renderPlane.vertexIndexMetalBuffer.length / MemoryLayout<UInt16>.size,
                    indexType: MTLIndexType.uint16,
                    indexBuffer: renderPlane.vertexIndexMetalBuffer,
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
