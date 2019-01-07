//
//  metal.h
//  HelloMetal
//
//  Created by Douglass Turner on 12/19/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

#ifndef metal_h
#define metal_h

// See: EIMath.swift for match: struct Vertex
struct _Vertex_ {
    float3 xyz;
    float3 n;
    float4 rgba;
    float2 st;
};


struct InterpolatedVertex {
    float4 xyzw [[position]]; // required
    float4 rgba;
    float2 st;
};

#endif /* metal_h */
