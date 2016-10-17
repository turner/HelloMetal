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

    var renderPlaneRenderPipelineState: MTLRenderPipelineState!
    var heroRenderPipelineState: MTLRenderPipelineState!

    var depthStencilState: MTLDepthStencilState!
    var commandQueue: MTLCommandQueue!
    var texture: MTLTexture!

    init(device: MTLDevice) {

        renderPlane = MetallicQuadModel(device: device)
        heroModel = MetallicQuadModel(device: device)

        camera = EISCamera()
        // viewing frustrum - eye looks along z-axis towards -z direction
        //                    +y up
        //                    +x to the right
//        camera.setTransform(location:GLKVector3(v:(0, 0, 2.5*8)), target:GLKVector3(v:(0, 0, 0)), approximateUp:GLKVector3(v:(0, 1, 0)))

        camera.setTransform(location:GLKVector3(v:(0, 0, 1000)), target:GLKVector3(v:(0, 0, 0)), approximateUp:GLKVector3(v:(0, 1, 0)))

//        To test render plane placement in camera frustrum
//        camera.setTransform(location:GLKVector3(v:(-100, 0, 1000)), target:GLKVector3(v:(100, -100, 0)), approximateUp:GLKVector3(v:(1, 1, 0)))

        guard let image = UIImage(named:"diagnostic") else {
            fatalError("Error: Can not create image")
        }
        
        let textureLoader = MTKTextureLoader(device: device)
        
        do {
            texture = try textureLoader.newTexture(with: image.cgImage!, options: nil)
        } catch {
            fatalError("Error: Can not load texture")
        }
        
        let library = device.newDefaultLibrary()

        let renderPlaneRenderPipelineDescriptor = MTLRenderPipelineDescriptor()

        renderPlaneRenderPipelineDescriptor.vertexFunction = library?.makeFunction(name: "showSTVertexShader")!
        renderPlaneRenderPipelineDescriptor.fragmentFunction = library?.makeFunction(name: "showSTFragmentShader")!

        renderPlaneRenderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        do {
            renderPlaneRenderPipelineState = try device.makeRenderPipelineState(descriptor: renderPlaneRenderPipelineDescriptor)
        } catch let e {
            Swift.print("\(e)")
        }

        let heroRenderPipelineDescriptor = MTLRenderPipelineDescriptor()

        heroRenderPipelineDescriptor.vertexFunction = library?.makeFunction(name: "helloTextureVertexShader")!
        heroRenderPipelineDescriptor.fragmentFunction = library?.makeFunction(name: "helloTextureFragmentShader")!

        heroRenderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        do {
            heroRenderPipelineState = try device.makeRenderPipelineState(descriptor: heroRenderPipelineDescriptor)
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
//        camera.setProjection(fovYDegrees:Float(45), aspectRatioWidthOverHeight:Float(view.bounds.size.width / view.bounds.size.height), near: 0, far: 10)
        camera.setProjection(fovYDegrees:Float(35), aspectRatioWidthOverHeight:Float(view.bounds.size.width / view.bounds.size.height), near: 200, far: 2000)
    }

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        reshape(view:view as! MetalView)
    }
    
    public func draw(in view: MTKView) {
        
        update(view: view as! MetalView, drawableSize: view.bounds.size)

        if let renderPassDescriptor = view.currentRenderPassDescriptor, let drawable = view.currentDrawable {

            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.3, 0.5, 0.5, 1.0)

            let commandBuffer = commandQueue.makeCommandBuffer()

            let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)

            renderCommandEncoder.setFrontFacing(.counterClockwise)
            renderCommandEncoder.setTriangleFillMode(.fill)
            renderCommandEncoder.setCullMode(.none)



            // render plane
            renderCommandEncoder.setRenderPipelineState(renderPlaneRenderPipelineState)
            renderCommandEncoder.setVertexBuffer(renderPlane.vertexMetalBuffer, offset: 0, at: 0)
            renderCommandEncoder.setVertexBuffer(renderPlane.transform.metalBuffer, offset: 0, at: 1)
            renderCommandEncoder.drawIndexedPrimitives(
                    type: .triangle,
                    indexCount: renderPlane.vertexIndexMetalBuffer.length / MemoryLayout<UInt16>.size,
                    indexType: MTLIndexType.uint16,
                    indexBuffer: renderPlane.vertexIndexMetalBuffer,
                    indexBufferOffset: 0)



//            // hero
            renderCommandEncoder.setRenderPipelineState(heroRenderPipelineState)
            renderCommandEncoder.setFragmentTexture(texture, at: 0)
            renderCommandEncoder.setVertexBuffer(heroModel.vertexMetalBuffer, offset: 0, at: 0)
            renderCommandEncoder.setVertexBuffer(heroModel.transform.metalBuffer, offset: 0, at: 1)
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
