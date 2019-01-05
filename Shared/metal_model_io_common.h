//
//  metal_model_io_common.h
//  HelloMetal
//
//  Created by Douglass Turner on 12/19/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

#ifndef metal_model_io_common_h
#define metal_model_io_common_h

struct xyz_n_st {
    float3 xyz [[ attribute(0) ]];
    float3 n   [[ attribute(1) ]];
    half2 st   [[ attribute(2) ]];
};

struct xyzw_n_st_rgba {
    float4 xyzw [[ position ]]; // required
    float3 n;
    float4 rgba;
    half2  st;
};

struct TransformPackage {
    float4x4 normalMatrix;
    float4x4 modelMatrix;
    float4x4 viewMatrix;
    float4x4 modelViewMatrix;
    float4x4 modelViewProjectionMatrix;
};

#endif /* metal_model_io_common_h */
