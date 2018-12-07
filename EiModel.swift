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
    var transform:GLKMatrix4
    var shader:EIShader

    init(model:EIModelProtocol, shader:EIShader, transform:GLKMatrix4) {
        self.model = model
        self.shader = shader
        self.transform = transform
    }
    
    public mutating func update(camera:EICamera, arcball:EIArcball) {
        model.update(camera: camera, arcBall: arcball, transform: self.transform)
    }
    
    public func encode(encoder:MTLRenderCommandEncoder) {
        encoder.EI_Configure(renderPipelineState: shader.pipelineState, model: model, textures: shader.textures)
    }
}
