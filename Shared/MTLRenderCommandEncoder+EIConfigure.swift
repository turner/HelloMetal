//
//  MTLRenderCommandEncoder+EIConfigure.swift
//  HelloMetal
//
//  Created by Douglass Turner on 12/13/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import MetalKit

extension MTLRenderCommandEncoder {
    
    func EIConfigure(renderPipelineState:MTLRenderPipelineState, model:EIMetalProtocol, textures:[MTLTexture]) {
        
        self.setRenderPipelineState(renderPipelineState)
        
        // vertices at buffer 0. In metal vertex shader see: [[buffer(0)]]
        self.setVertexBuffer(model.getVertexMetalBuffer(), offset: 0, index: 0)
        
        // transforms at buffer 1. In metal vertex shader see: [[buffer(1)]]
        self.setVertexBuffer(model.getMetallicTransformMetalBuffer(), offset: 0, index: 1)
        
        // assign texture indices. So: [[texture(0)]], [[texture(1)]], etc.
        for i in 0..<textures.count {
            let texture = textures[ i ]
            self.setFragmentTexture(texture, index: i)
        }
        
        self.drawIndexedPrimitives(type: model.getPrimitiveType(), indexCount: model.getIndexCount(), indexType: model.getIndexType(), indexBuffer: model.getIndexBuffer(), indexBufferOffset: 0)
    }
    
}
