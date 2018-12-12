//
//  EIQuad+EIModelProtocol.swift
//  Hello
//
//  Created by Douglass Turner on 12/2/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import Metal
import GLKit
extension EIQuad : EIModelProtocol {

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
    
    public mutating func update(camera:EICamera, arcBall:EIArcball, transformer:() -> GLKMatrix4) {
        metallicTransform.update(camera: camera, transformer: {
            transformer()
        })
        
    }

}
