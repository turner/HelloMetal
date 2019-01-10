//
//  EIQuad.swift
//  HelloMetal
//
//  Created by Douglass Turner on 9/11/16.
//  Copyright © 2016 Elastic Image Software. All rights reserved.
//

import Metal
import GLKit

struct EIQuad {

    var vertexMetalBuffer: MTLBuffer
    var vertexIndexMetalBuffer: MTLBuffer

    var indexCount: Int {
        return vertexIndexMetalBuffer.length / MemoryLayout<UInt16>.size
    }

    var primitiveType: MTLPrimitiveType {
        return .triangle
    }

    var indexType: MTLIndexType {
        return .uint16
    }

    let metalVertexDescriptor:MTLVertexDescriptor? = .none

    let vertices = [
        Vertex(xyz: GLKVector3(v:(-1, -1,  0)), n: GLKVector3(v:(0, 0, 1)), rgba: GLKVector4(v:(1, 0, 0, 1)), st: GLKVector2(v:(0, 1))),
        Vertex(xyz: GLKVector3(v:( 1, -1,  0)), n: GLKVector3(v:(0, 0, 1)), rgba: GLKVector4(v:(0, 1, 0, 1)), st: GLKVector2(v:(1, 1))),
        Vertex(xyz: GLKVector3(v:( 1,  1,  0)), n: GLKVector3(v:(0, 0, 1)), rgba: GLKVector4(v:(0, 0, 1, 1)), st: GLKVector2(v:(1, 0))),
        Vertex(xyz: GLKVector3(v:(-1,  1,  0)), n: GLKVector3(v:(0, 0, 1)), rgba: GLKVector4(v:(1, 1, 0, 1)), st: GLKVector2(v:(0, 0))),
    ]

    let vertexIndices: [UInt16] =
            [
                0, 1, 2,
                2, 3, 0
            ]

    init(device: MTLDevice) {
        
        guard let vmb = device.makeBuffer(bytes: vertices, length: MemoryLayout<Vertex>.size * vertices.count, options: []) else {
            fatalError("Error: Can not create vertex buffer for EIQuad")
        }

        vertexMetalBuffer = vmb
        
        guard let vimb = device.makeBuffer(bytes:vertexIndices, length: MemoryLayout<UInt16>.size * vertexIndices.count , options: []) else {
            fatalError("Error: Can not create vertex index buffer for EIQuad")
        }
        
        vertexIndexMetalBuffer = vimb
    }
}
