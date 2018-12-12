//
//  EiModel.swift
//  HelloMetal
//
//  Created by Douglass Turner on 12/7/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import Metal
import GLKit
struct EIModel {
    
    var model:EIModelProtocol
    var shader:EIShader
    let transformer:() -> GLKMatrix4
    
    init(model:EIModelProtocol, shader:EIShader, transformer:@escaping () -> GLKMatrix4) {
        self.model = model
        self.shader = shader
        self.transformer = transformer
    }
    
    public mutating func update(camera:EICamera, arcball:EIArcball) {
        model.update(camera: camera, arcBall: arcball, transformer: transformer)
    }

    public func encode(encoder:MTLRenderCommandEncoder) {
        encoder.EI_Configure(renderPipelineState: shader.pipelineState, model: model, textures: shader.textures)
    }

    public func renderPassEncode(encoder:MTLRenderCommandEncoder, textures:[MTLTexture]) {
        encoder.EI_Configure(renderPipelineState: shader.pipelineState, model: model, textures: textures)
    }
}
