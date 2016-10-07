//
//  Renderer.swift
//  HelloMetal
//
//  Created by Douglass Turner on 9/11/16.
//  Copyright © 2016 Elastic Image Software. All rights reserved.
//

import MetalKit
import GLKit

struct RendererIOS {

    var metallicTransform: MetallicTransform!
//    var metallicModel: MetallicBoxModel!
    var metallicModel: MetallicQuadModel!
    var camera: EISCamera!

    var renderPipelineState: MTLRenderPipelineState!
    var depthStencilState: MTLDepthStencilState!
    var commandQueue: MTLCommandQueue!
    var texture: MTLTexture!

    init(device: MTLDevice) {

        self.metallicTransform = MetallicTransform(device: device)
//        self.metallicModel = MetallicBoxModel(device: device)
        self.metallicModel = MetallicQuadModel(device: device)

        self.camera = EISCamera()
        // viewing frustrum - eye looks along z-axis towards -z direction
        //                    +y up
        //                    +x to the right
        self.camera.setTransform(location:GLKVector3(v:(0, 0, 8)), target:GLKVector3(v:(0, 0, 0)), approximateUp:GLKVector3(v:(0, 1, 0)))
        
        guard let image = UIImage(named:"diagnostic") else {
            fatalError("Error: Can not create image")
        }
        
        let textureLoader = MTKTextureLoader(device: device)
        
        do {
            self.texture = try textureLoader.newTexture(with: image.cgImage!, options: nil)
        } catch {
            fatalError("Error: Can not load texture")
        }
        
        let library = device.newDefaultLibrary()
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        
        renderPipelineDescriptor.vertexFunction = library?.makeFunction(name: "helloTextureVertexShader")!
        renderPipelineDescriptor.fragmentFunction = library?.makeFunction(name: "helloTextureFragmentShader")!
        
//        renderPipelineDescriptor.vertexFunction = library?.makeFunction(name: "showSTVertexShader")!
//        renderPipelineDescriptor.fragmentFunction = library?.makeFunction(name: "showSTFragmentShader")!
        
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
//        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .rgba8Unorm
        
        do {
            renderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        } catch let e {
            Swift.print("\(e)")
        }

        commandQueue = device.makeCommandQueue()

    }

    mutating func update(drawableSize:CGSize) {

        metallicTransform.transforms.modelMatrix =
            GLKMatrix4MakeTranslation(0, 0, 0) * GLKMatrix4MakeScale(3, 2, 1)

        self.camera.setProjection(fovYDegrees:Float(45), aspectRatioWidthOverHeight:Float(drawableSize.width / drawableSize.height), near: 0, far: 10)
        
        metallicTransform.transforms.modelViewProjectionMatrix =
            camera.projectionTransform * camera.transform * metallicTransform.transforms.modelMatrix

        metallicTransform.update()

    }

    func draw(view:MTKView) {

        if let renderPassDescriptor = view.currentRenderPassDescriptor, let drawable = view.currentDrawable {

            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.3, 0.5, 0.5, 1.0)

            let commandBuffer = self.commandQueue.makeCommandBuffer()
            let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)

            renderCommandEncoder.setFragmentTexture(self.texture, at: 0)
            
            renderCommandEncoder.setRenderPipelineState(self.renderPipelineState)

            renderCommandEncoder.setFrontFacing(.counterClockwise)
            renderCommandEncoder.setCullMode(.back)

            renderCommandEncoder.setVertexBuffer(self.metallicModel.vertexMetalBuffer, offset: 0, at: 0)
            renderCommandEncoder.setVertexBuffer(self.metallicTransform.metalBuffer, offset: 0, at: 1)

            renderCommandEncoder.drawIndexedPrimitives(
                type: .triangle,
                indexCount: self.metallicModel.vertexIndexMetalBuffer.length / MemoryLayout<UInt16>.size,
                indexType: MTLIndexType.uint16,
                indexBuffer: self.metallicModel.vertexIndexMetalBuffer,
                indexBufferOffset: 0)
            
            renderCommandEncoder.endEncoding()

            commandBuffer.present(drawable)
            commandBuffer.commit()
        }

    }

}
