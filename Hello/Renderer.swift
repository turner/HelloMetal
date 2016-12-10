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

    var camera:EICamera

    var heroModel: EIQuad
    var heroModelTexture:MTLTexture
    var heroModelPipelineState:MTLRenderPipelineState!

    var commandQueue:MTLCommandQueue
    
    var view:MTKView
    var device:MTLDevice

    init(view: MTKView, device: MTLDevice) {
        
        self.view = view
        self.device = device
        
        let library = device.newDefaultLibrary()
        
        camera = EICamera(location:GLKVector3(v:(0, 0, 1000)), target:GLKVector3(v:(0, 0, 0)), approximateUp:GLKVector3(v:(0, 1, 0)))

        heroModel = EIQuad(device: device)

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

//                                                vertexShaderName:"showSTVertexShader",
//                                                fragmentShaderName:"showSTFragmentShader",

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
        reshape(view:view as! EIView)
    }

    func reshape (view: EIView) {
        view.arcBall.reshape(viewBounds: view.bounds)
        camera.setProjection(fovYDegrees:Float(35), aspectRatioWidthOverHeight:Float(view.bounds.size.width / view.bounds.size.height), near: 200, far: 8000)
    }

    func update(view: EIView, drawableSize:CGSize) {

        heroModel.metallicTransform.update(camera: camera, transformer: {
            return view.arcBall.rotationMatrix * GLKMatrix4MakeScale(150, 150, 1)
        })
        
    }

    public func draw(in view: MTKView) {

        update(view: view as! EIView, drawableSize: view.bounds.size)

        // final pass
        if let passDescriptor = view.currentRenderPassDescriptor, let drawable = view.currentDrawable {

            passDescriptor.colorAttachments[ 0 ].clearColor = MTLClearColorMake(0.5, 0.5, 0.5, 1.0)
//            passDescriptor.colorAttachments[ 0 ].clearColor = MTLClearColorMake(1,1,1,1)

            let commandBuffer = commandQueue.makeCommandBuffer()

            let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor)

            renderCommandEncoder.setFrontFacing(.counterClockwise)
            
            renderCommandEncoder.setTriangleFillMode(.fill)
//            renderCommandEncoder.setTriangleFillMode(.lines)
            
            renderCommandEncoder.setRenderPipelineState(heroModelPipelineState)
            renderCommandEncoder.setVertexBuffer(heroModel.vertexMetalBuffer, offset: 0, at: 0)
            renderCommandEncoder.setVertexBuffer(heroModel.metallicTransform.metalBuffer, offset: 0, at: 1)
            renderCommandEncoder.setFragmentTexture(heroModelTexture, at: 0)
            renderCommandEncoder.drawIndexedPrimitives(
                    type: .triangle,
                    indexCount: heroModel.indexCount,
                    indexType: MTLIndexType.uint16,
                    indexBuffer: heroModel.vertexIndexMetalBuffer,
                    indexBufferOffset: 0)

            renderCommandEncoder.endEncoding()

            commandBuffer.present(drawable)
            commandBuffer.commit()
        }

    }

}
