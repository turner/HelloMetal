//
//  EIMesh+EIModelProtocol.swift
//  Hello
//
//  Created by Douglass Turner on 12/2/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import Metal

extension EIMesh : EIModelProtocol {
    
    func getVertexMetalBuffer() -> MTLBuffer {
        return vertexMetalBuffer
    }
    
    func getMetallicTransformMetalBuffer() -> MTLBuffer {
        return metallicTransform.metalBuffer
    }
    
    func getPrimitiveType() -> MTLPrimitiveType {
        return primitiveType
    }
    
    func getIndexCount() -> Int {
        return indexCount
    }
    
    func getIndexType() -> MTLIndexType {
        return indexType
    }
    
    func getIndexBuffer() -> MTLBuffer {
        return vertexIndexMetalBuffer
    }
    
}
