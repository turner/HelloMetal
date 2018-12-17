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
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        // n
        vertexDescriptor.attributes[1].format = .float3
        vertexDescriptor.attributes[1].offset = 12
        vertexDescriptor.attributes[1].bufferIndex = 0
        
        // st
        vertexDescriptor.attributes[2].format = .half2
        vertexDescriptor.attributes[2].offset = 24
        vertexDescriptor.attributes[2].bufferIndex = 0
        
        // Single interleaved buffer.
        vertexDescriptor.layouts[0].stride = 28
        vertexDescriptor.layouts[0].stepRate = 1
        vertexDescriptor.layouts[0].stepFunction = .perVertex
        
        return vertexDescriptor
        
    }
}


