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

    var renderPlaneTransform: MetallicTransform!
    var renderPlane: MetallicQuadModel!

    var heroModelTransform: MetallicTransform!
    var heroModel: MetallicQuadModel!

    var camera: EISCamera!

    var renderPipelineState: MTLRenderPipelineState!
    var depthStencilState: MTLDepthStencilState!
    var commandQueue: MTLCommandQueue!
    var texture: MTLTexture!

    init(device: MTLDevice) {

        renderPlaneTransform = MetallicTransform(device: device)
        renderPlane = MetallicQuadModel(device: device)

        heroModelTransform = MetallicTransform(device: device)
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
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        
//        renderPipelineDescriptor.vertexFunction = library?.makeFunction(name: "helloTextureVertexShader")!
//        renderPipelineDescriptor.fragmentFunction = library?.makeFunction(name: "helloTextureFragmentShader")!
        
        renderPipelineDescriptor.vertexFunction = library?.makeFunction(name: "showSTVertexShader")!
        renderPipelineDescriptor.fragmentFunction = library?.makeFunction(name: "showSTFragmentShader")!
        
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        do {
            renderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        } catch let e {
            Swift.print("\(e)")
        }

        commandQueue = device.makeCommandQueue()

    }

    func update(view: MetalView, drawableSize:CGSize) {

        let degrees = camera.fovYDegrees/2
        let radians = GLKMathDegreesToRadians(degrees)
        let tanRadians = tan(radians)
        
        let fudge = 0.9 * camera.far
        let dimension = fudge * tanRadians
        
        let xform = camera.renderPlaneTransform(distanceFromCamera: fudge)
        let xScale = dimension*camera.aspectRatioWidthOverHeight
        let yScale = dimension
        let scale = GLKMatrix4MakeScale(xScale, yScale, 1)
        
        // render plane
        renderPlaneTransform.transforms.modelMatrix = xform * scale
        renderPlaneTransform.transforms.modelViewProjectionMatrix = camera.projectionTransform * camera.transform * renderPlaneTransform.transforms.modelMatrix
        renderPlaneTransform.update()


        // hero model
        heroModelTransform.transforms.modelMatrix = view.arcBall.rotationMatrix * GLKMatrix4MakeScale(100, 200, 1)
        heroModelTransform.transforms.modelViewProjectionMatrix = camera.projectionTransform * camera.transform * heroModelTransform.transforms.modelMatrix
        heroModelTransform.update()

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

            let commandBuffer = self.commandQueue.makeCommandBuffer()
            let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)

            renderCommandEncoder.setFragmentTexture(self.texture, at: 0)
            
            renderCommandEncoder.setRenderPipelineState(self.renderPipelineState)

            renderCommandEncoder.setFrontFacing(.counterClockwise)

            renderCommandEncoder.setTriangleFillMode(.fill)
//            renderCommandEncoder.setTriangleFillMode(.lines)

//            renderCommandEncoder.setCullMode(.back)
            renderCommandEncoder.setCullMode(.none)



            //
            renderCommandEncoder.setVertexBuffer(renderPlane.vertexMetalBuffer, offset: 0, at: 0)
            renderCommandEncoder.setVertexBuffer(renderPlaneTransform.metalBuffer, offset: 0, at: 1)

            renderCommandEncoder.drawIndexedPrimitives(
                    type: .triangle,
                    indexCount: renderPlane.vertexIndexMetalBuffer.length / MemoryLayout<UInt16>.size,
                    indexType: MTLIndexType.uint16,
                    indexBuffer: renderPlane.vertexIndexMetalBuffer,
                    indexBufferOffset: 0)

            //
//            renderCommandEncoder.setVertexBuffer(heroModel.vertexMetalBuffer, offset: 0, at: 0)
//            renderCommandEncoder.setVertexBuffer(heroModelTransform.metalBuffer, offset: 0, at: 1)
//
//            renderCommandEncoder.drawIndexedPrimitives(
//                    type: .triangle,
//                    indexCount: heroModel.vertexIndexMetalBuffer.length / MemoryLayout<UInt16>.size,
//                    indexType: MTLIndexType.uint16,
//                    indexBuffer: heroModel.vertexIndexMetalBuffer,
//                    indexBufferOffset: 0)




            renderCommandEncoder.endEncoding()

            commandBuffer.present(drawable)
            commandBuffer.commit()
        }

    }

}
