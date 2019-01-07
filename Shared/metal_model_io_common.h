//
//  metal_model_io_common.h
//  HelloMetal
//
//  Created by Douglass Turner on 12/19/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

#ifndef metal_model_io_common_h
#define metal_model_io_common_h

// See: MTLVertexDescriptor+EIMake.swift for association with
// MTLVertexDescriptor
struct xyz_n_st {
    float3 xyz [[ attribute(_xyz_) ]];
    float3 n   [[ attribute(_n_) ]];
    half2 st   [[ attribute(_st_) ]];
};

// returned struct from vertex shader
struct xyzw_n_st_rgba {
    float4 xyzw [[ position ]]; // required
    float3 n;
    float4 rgba;
    half2  st;
};

#endif /* metal_model_io_common_h */
