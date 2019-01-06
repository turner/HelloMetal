//
//  ei_buffer_indices.h
//  HelloMetal
//
//  Created by Douglass Turner on 1/6/19.
//  Copyright © 2019 Elastic Image Software. All rights reserved.
//

#ifndef ei_buffer_indices_h
#define ei_buffer_indices_h

// See matching: enum VertexBufferIndex in EIBufferIndices.swift.swift
enum VertexBufferIndex {
    _attributes_ = 0,
    _transform_ = 1
};

// See matching: enum VertexDescriptorAttributesIndex in EIBufferIndices.swift.swift
enum VertexDescriptorAttributesIndex {
    _xyz_ = 0,
    _n_ = 1,
    _st_ = 2,
    _tangent_ = 3
};

#endif /* ei_buffer_indices_h */
