//
//  MTLRenderCommandEncoder+EI_Configure.swift
//  HelloMetal
//
//  Created by Douglass Turner on 12/13/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import MetalKit

extension MTLRenderCommandEncoder {
    
    func EI_Configure(renderPipelineState:MTLRenderPipelineState, model:EIModelProtocol, textures:[MTLTexture]) {
        
        self.setRenderPipelineState(renderPipelineState)
        
        self.setVertexBuffer(model.getVertexMetalBuffer(), offset: 0, index: 0)
        self.setVertexBuffer(model.getMetallicTransformMetalBuffer(), offset: 0, index: 1)
        
        for i in 0..<textures.count {
            let texture = textures[ i ]
            self.setFragmentTexture(texture, index: i)
        }
        
        self.drawIndexedPrimitives(type: model.getPrimitiveType(), indexCount: model.getIndexCount(), indexType: model.getIndexType(), indexBuffer: model.getIndexBuffer(), indexBufferOffset: 0)
    }
    
}
