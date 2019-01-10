//
//  MTLRenderCommandEncoder+EIConfigure.swift
//  HelloMetal
//
//  Created by Douglass Turner on 12/13/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import MetalKit

extension MTLRenderCommandEncoder {
    
    func EIConfigure(renderPipelineState:MTLRenderPipelineState, model:EIModel, textures:[MTLTexture]) {
        
        setRenderPipelineState(renderPipelineState)
        
        // In metal vertex shader see: [[buffer(_attributes_)]]
        setVertexBuffer(model.geometry.getVertexMetalBuffer(), offset: 0, index: VertexBufferIndex._attributes_.rawValue)
        
        // In metal vertex shader see: [[buffer(_transform_)]]
        setVertexBytes(&(model.transform), length: MemoryLayout<EITransform>.size, index: VertexBufferIndex._transform_.rawValue)

        // assign texture indices. So: [[texture(0)]], [[texture(1)]], etc.
        for i in 0..<textures.count {
            let texture = textures[ i ]
            setFragmentTexture(texture, index: i)
        }
        
        drawIndexedPrimitives(type: model.geometry.getPrimitiveType(), indexCount: model.geometry.getIndexCount(), indexType: model.geometry.getIndexType(), indexBuffer: model.geometry.getIndexBuffer(), indexBufferOffset: 0)
    }
    
}
