//
//  metal_common.h
//  HelloMetal
//
//  Created by Douglass Turner on 12/19/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

#ifndef metal_common_h
#define metal_common_h

// See: EIMath.swift for match: struct Vertex
struct _Vertex_ {
    float3 xyz;
    float3 n;
    float4 rgba;
    float2 st;
};

// See: EITransform.swift for match: struct Transform
struct _Transforms_ {
    float4x4 normalMatrix;
    float4x4 modelMatrix;
    float4x4 viewMatrix;
    float4x4 modelViewMatrix;
    float4x4 modelViewProjectionMatrix;
};


struct InterpolatedVertex {
    float4 xyzw [[position]]; // required
    float4 rgba;
    float2 st;
};

#endif /* metal_common_h */
