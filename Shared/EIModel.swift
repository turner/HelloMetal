//
//  EIModel.swift
//  HelloMetal
//
//  Created by Douglass Turner on 12/7/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import Metal
import GLKit
struct EIModel {
    
    var model:EIMetalProtocol
    var shader:EIShader
    var transformer:() -> GLKMatrix4
    var pipelineState:MTLRenderPipelineState
    
    init(view:EIView, model:EIMetalProtocol, shader:EIShader, transformer:@escaping () -> GLKMatrix4) {
        
        let pipelineDescriptor =
            MTLRenderPipelineDescriptor.EIInit(library:view.defaultLibrary, vertexShaderName:shader.vertex, fragmentShaderName:shader.fragment, sampleCount:view.sampleCount, colorPixelFormat:view.colorPixelFormat, vertexDescriptor:model.getVertexDescriptor())
        do {
            pipelineState = try view.device!.makeRenderPipelineState(descriptor:pipelineDescriptor)
        } catch {
            fatalError("Error: Can not create render pipeline state")
        }

        self.model = model
        self.shader = shader
        self.transformer = transformer
    }

    init(view:EIView, model:EIMetalProtocol, shader:EIShader) {
        
        let pipelineDescriptor =
            MTLRenderPipelineDescriptor.EIInit(library:view.defaultLibrary, vertexShaderName:shader.vertex, fragmentShaderName:shader.fragment, sampleCount:view.sampleCount, colorPixelFormat:view.colorPixelFormat, vertexDescriptor:model.getVertexDescriptor())
        do {
            pipelineState = try view.device!.makeRenderPipelineState(descriptor:pipelineDescriptor)
        } catch {
            fatalError("Error: Can not create render pipeline state")
        }
        
        self.model = model
        self.shader = shader
        self.transformer = { return GLKMatrix4Identity }
    }

    public mutating func update(camera:EICamera, arcball:EIArcball) {
        model.update(camera: camera, arcBall: arcball, transformer: transformer)
    }

    public func encode(encoder:MTLRenderCommandEncoder) {
        encoder.EIConfigure(renderPipelineState: pipelineState, model: model, textures: shader.textures)
    }

    public func renderPassEncode(encoder:MTLRenderCommandEncoder, textures:[MTLTexture]) {
        encoder.EIConfigure(renderPipelineState: pipelineState, model: model, textures: textures)
    }
}
