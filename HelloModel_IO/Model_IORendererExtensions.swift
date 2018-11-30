//
//  Model_IORendererExtensions.swift
//  HelloModel_IO
//
//  Created by Douglass Turner on 11/30/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import MetalKit

extension MTLRenderCommandEncoder {
    
    func EI_ConfigureWithEIMesh(renderPipelineState:MTLRenderPipelineState, model:EIMesh, textures:[MTLTexture]) {
        
        self.setRenderPipelineState(renderPipelineState)
        
        self.setVertexBuffer(model.vertexMetalBuffer, offset: 0, index: 0)
        self.setVertexBuffer(model.metallicTransform.metalBuffer, offset: 0, index: 1)
        
        for i in 0..<textures.count {
            let texture = textures[ i ]
            self.setFragmentTexture(texture, index: i)
        }
        
        self.drawIndexedPrimitives(type: model.primitiveType, indexCount: model.indexCount, indexType: model.indexType, indexBuffer: model.vertexIndexMetalBuffer, indexBufferOffset: 0)
        
    }
        
}
