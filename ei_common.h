//
//  ei_common.h
//  HelloMetal
//
//  Created by Douglass Turner on 1/6/19.
//  Copyright © 2019 Elastic Image Software. All rights reserved.
//

#ifndef ei_common_h
#define ei_common_h

// See: EITransform.swift for match: struct Transform
struct _Transforms_ {
    float4x4 normalMatrix;
    float4x4 modelMatrix;
    float4x4 viewMatrix;
    float4x4 modelViewMatrix;
    float4x4 modelViewProjectionMatrix;
};

// See EICommon.swift for matching: enum VertexBufferIndex
enum VertexBufferIndex {
    _attributes_ = 0,
    _transform_ = 1
};

// See EICommon.swift for matching: enum VertexDescriptorAttributesIndex
enum VertexDescriptorAttributesIndex {
    _xyz_ = 0,
    _n_ = 1,
    _st_ = 2,
    _tangent_ = 3
};

#endif /* ei_common_h */
