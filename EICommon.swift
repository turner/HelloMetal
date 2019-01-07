//
//  EICommon.swift
//  HelloMetal
//
//  Created by Douglass Turner on 1/6/19.
//  Copyright © 2019 Elastic Image Software. All rights reserved.
//

import GLKit

// See ei_common.h for matching struct Transform
struct Transform {
    var normalMatrix = GLKMatrix4Identity
    var modelMatrix = GLKMatrix4Identity
    var viewMatrix = GLKMatrix4Identity
    var modelViewMatrix = GLKMatrix4Identity
    var modelViewProjectionMatrix = GLKMatrix4Identity
}

// See ei_common.h for matching enum VertexBufferIndex
enum VertexBufferIndex: Int {
    case _attributes_ = 0
    case _transform_ = 1
}

// See ei_common.h for matching enum VertexDescriptorAttributesIndex
enum VertexDescriptorAttributesIndex: Int {
    case _xyz_ = 0
    case _n_ = 1
    case _st_ = 2
    case _tangent_ = 3
}
