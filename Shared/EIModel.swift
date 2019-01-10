//
//  EIModel.swift
//  HelloMetal
//
//  Created by Douglass Turner on 12/7/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import Metal
import GLKit
class EIModel {
    
    var transform: EITransform
    var geometry:EIMetalProtocol
    var shader:EIShader
    var transformer:() -> GLKMatrix4
    var pipelineState:MTLRenderPipelineState
    
    init(view:EIView, model:EIMetalProtocol, shader:EIShader, transformer:@escaping () -> GLKMatrix4) {
        
        let pipelineDescriptor =
            MTLRenderPipelineDescriptor.EIMake(library:view.defaultLibrary, vertexShaderName:shader.vertex, fragmentShaderName:shader.fragment, sampleCount:view.sampleCount, colorPixelFormat:view.colorPixelFormat, vertexDescriptor:model.getVertexDescriptor())
        do {
            pipelineState = try view.device!.makeRenderPipelineState(descriptor:pipelineDescriptor)
        } catch {
            fatalError("Error: Can not create render pipeline state")
        }

        self.transform = EITransform()
        self.geometry = model
        self.shader = shader
        self.transformer = transformer
    }

    init(view:EIView, model:EIMetalProtocol, shader:EIShader) {
        
        let pipelineDescriptor =
            MTLRenderPipelineDescriptor.EIMake(library:view.defaultLibrary, vertexShaderName:shader.vertex, fragmentShaderName:shader.fragment, sampleCount:view.sampleCount, colorPixelFormat:view.colorPixelFormat, vertexDescriptor:model.getVertexDescriptor())
        do {
            pipelineState = try view.device!.makeRenderPipelineState(descriptor:pipelineDescriptor)
        } catch {
            fatalError("Error: Can not create render pipeline state")
        }
        
        self.transform = EITransform()
        self.geometry = model
        self.shader = shader
        self.transformer = { return GLKMatrix4Identity }
    }

    public func update(camera:EICamera) {
        transform.update(camera: camera, transformer: {
            transformer()
        })
    }

    public func encode(encoder:MTLRenderCommandEncoder) {
        encoder.EIConfigure(renderPipelineState: pipelineState, model: self, textures: shader.textures)
    }

    public func renderPassEncode(encoder:MTLRenderCommandEncoder, textures:[MTLTexture]) {
        encoder.EIConfigure(renderPipelineState: pipelineState, model: self, textures: textures)
    }
}
