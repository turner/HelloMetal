//
//  MetallicModel.swift
//  HelloMetal
//
//  Created by Douglass Turner on 9/11/16.
//  Copyright © 2016 Elastic Image Software. All rights reserved.
//

import Metal
import GLKit

struct MetallicQuadModel {

    let vertices = [
            Vertex(xyzw: GLKVector4(v:(-1.0, -1.0,  0.0, 1.0)), rgba: GLKVector4(v:(1, 1, 1, 1)), st: GLKVector2(v:(0, 1))),
            Vertex(xyzw: GLKVector4(v:( 1.0, -1.0,  0.0, 1.0)), rgba: GLKVector4(v:(1, 0, 0, 1)), st: GLKVector2(v:(1, 1))),
            Vertex(xyzw: GLKVector4(v:( 1.0,  1.0,  0.0, 1.0)), rgba: GLKVector4(v:(1, 1, 0, 1)), st: GLKVector2(v:(1, 0))),
            Vertex(xyzw: GLKVector4(v:(-1.0,  1.0,  0.0, 1.0)), rgba: GLKVector4(v:(0, 1, 0, 1)), st: GLKVector2(v:(0, 0))),
    ]

    let vertexIndices: [UInt16] =
    [
            0, 1, 2,
            2, 3, 0
    ]

    var vertexMetalBuffer: MTLBuffer!
    var vertexIndexMetalBuffer: MTLBuffer!

    init(device: MTLDevice) {
        let vertexSize = MemoryLayout<Vertex>.size
        let vertexCount = self.vertices.count

        self.vertexMetalBuffer      = device.makeBuffer(bytes: self.vertices,      length: vertexSize * vertexCount,       options: [])
        self.vertexIndexMetalBuffer = device.makeBuffer(bytes: self.vertexIndices, length: MemoryLayout<UInt16>.size * self.vertexIndices.count , options: [])
    }

}

//struct MetallicBoxModel {
//
//    let vertices = [
//            Vertex(xyzw: GLKVector4(v:(-1.0, -1.0,  1.0, 1.0)), rgba: GLKVector4(v:(1, 1, 1, 1)), st: GLKVector2(v:(0, 0))),
//            Vertex(xyzw: GLKVector4(v:( 1.0, -1.0,  1.0, 1.0)), rgba: GLKVector4(v:(1, 0, 0, 1)), st: GLKVector2(v:(0, 0))),
//            Vertex(xyzw: GLKVector4(v:( 1.0,  1.0,  1.0, 1.0)), rgba: GLKVector4(v:(1, 1, 0, 1)), st: GLKVector2(v:(0, 0))),
//            Vertex(xyzw: GLKVector4(v:(-1.0,  1.0,  1.0, 1.0)), rgba: GLKVector4(v:(0, 1, 0, 1)), st: GLKVector2(v:(0, 0))),
//            Vertex(xyzw: GLKVector4(v:(-1.0, -1.0, -1.0, 1.0)), rgba: GLKVector4(v:(0, 0, 1, 1)), st: GLKVector2(v:(0, 0))),
//            Vertex(xyzw: GLKVector4(v:( 1.0, -1.0, -1.0, 1.0)), rgba: GLKVector4(v:(1, 0, 1, 1)), st: GLKVector2(v:(0, 0))),
//            Vertex(xyzw: GLKVector4(v:( 1.0,  1.0, -1.0, 1.0)), rgba: GLKVector4(v:(0, 0, 0, 1)), st: GLKVector2(v:(0, 0))),
//            Vertex(xyzw: GLKVector4(v:(-1.0,  1.0, -1.0, 1.0)), rgba: GLKVector4(v:(0, 1, 1, 1)), st: GLKVector2(v:(0, 0)))
//    ]
//
//    let vertexIndices: [UInt16] = [
//            0, 1, 2, 2, 3, 0,   // front
//            1, 5, 6, 6, 2, 1,   // right
//            3, 2, 6, 6, 7, 3,   // top
//            4, 5, 1, 1, 0, 4,   // bottom
//            4, 0, 3, 3, 7, 4,   // left
//            7, 6, 5, 5, 4, 7,   // back
//    ]
//
//    var vertexMetalBuffer: MTLBuffer!
//    var vertexIndexMetalBuffer: MTLBuffer!
//
//    init(device: MTLDevice) {
//        self.vertexMetalBuffer      = device.makeBuffer(bytes: self.vertices,      length: MemoryLayout<Vertex>.size * self.vertices.count,       options: [])
//        self.vertexIndexMetalBuffer = device.makeBuffer(bytes: self.vertexIndices, length: MemoryLayout<UInt16>.size * self.vertexIndices.count , options: [])
//    }
//
//}
