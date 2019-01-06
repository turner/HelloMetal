//
//  MTLVertexDescriptor+xyz_n_st_vertexDescriptor.swift
//  HelloMetal
//
//  Created by Douglass Turner on 12/13/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import MetalKit

extension MTLVertexDescriptor {
    
    class func xyz_n_st_vertexDescriptor() -> MTLVertexDescriptor {
        
        // Metal vertex descriptor
        let vertexDescriptor = MTLVertexDescriptor()
        
        // xyz
        vertexDescriptor.attributes[VertexDescriptorAttributesIndex._xyz_.rawValue] =
            MTLVertexAttributeDescriptor(.float3, 0, VertexBufferIndex._attributes_.rawValue)
        
        // n
        vertexDescriptor.attributes[VertexDescriptorAttributesIndex._n_.rawValue] =
            MTLVertexAttributeDescriptor(.float3, 12, VertexBufferIndex._attributes_.rawValue)
        
        // st
        vertexDescriptor.attributes[VertexDescriptorAttributesIndex._st_.rawValue] =
            MTLVertexAttributeDescriptor(.half2, 24, VertexBufferIndex._attributes_.rawValue)
        
        // Single interleaved buffer.
        vertexDescriptor.layouts[VertexBufferIndex._attributes_.rawValue].stride = 28
        vertexDescriptor.layouts[VertexBufferIndex._attributes_.rawValue].stepRate = 1
        vertexDescriptor.layouts[VertexBufferIndex._attributes_.rawValue].stepFunction = .perVertex
        
        return vertexDescriptor
        
    }

}

extension MTLVertexAttributeDescriptor {
    convenience init(_ format:MTLVertexFormat, _ offset: Int, _ bufferIndex: Int) {
        self.init()
        self.format = format
        self.offset = offset
        self.bufferIndex = bufferIndex
    }
}
