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
        
        setRenderPipelineState(renderPipelineState)
        
        // In metal vertex shader see: [[buffer(_attributes_)]]
        setVertexBuffer(model.getVertexMetalBuffer(), offset: 0, index: VertexBufferIndex._attributes_.rawValue)
        
        // In metal vertex shader see: [[buffer(_transform_)]]
        setVertexBuffer(model.getMetallicTransformMetalBuffer(), offset: 0, index: VertexBufferIndex._transform_.rawValue)
        
        // assign texture indices. So: [[texture(0)]], [[texture(1)]], etc.
        for i in 0..<textures.count {
            let texture = textures[ i ]
            setFragmentTexture(texture, index: i)
        }
        
        drawIndexedPrimitives(type: model.getPrimitiveType(), indexCount: model.getIndexCount(), indexType: model.getIndexType(), indexBuffer: model.getIndexBuffer(), indexBufferOffset: 0)
    }
    
}
