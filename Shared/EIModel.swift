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
    
    init(model:EIMetalProtocol, shader:EIShader) {
        self.model = model
        self.shader = shader
        self.transformer = { return GLKMatrix4Identity }
    }
    
    init(model:EIMetalProtocol, shader:EIShader, transformer:@escaping () -> GLKMatrix4) {
        self.model = model
        self.shader = shader
        self.transformer = transformer
    }

    public mutating func update(camera:EICamera, arcball:EIArcball) {
        model.update(camera: camera, arcBall: arcball, transformer: transformer)
    }

    public func encode(encoder:MTLRenderCommandEncoder) {
        encoder.EIConfigure(renderPipelineState: shader.pipelineState, model: model, textures: shader.textures)
    }

    public func renderPassEncode(encoder:MTLRenderCommandEncoder, textures:[MTLTexture]) {
        encoder.EIConfigure(renderPipelineState: shader.pipelineState, model: model, textures: textures)
    }
}
