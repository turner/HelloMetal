#include <metal_stdlib>
using namespace metal;

struct xyz_n_st {
    float3 xyz [[ attribute(0) ]];
    float3 n   [[ attribute(1) ]];
    half2 st   [[ attribute(2) ]];
};

struct xyzw_n_st_rgba {
    float4 xyzw [[ position ]];
    float3 n;
    half2  st;
    half4  rgba;
};

struct TransformPackage {
    float3x3 normalMatrix;    
    float4x4 modelMatrix;
    float4x4 viewMatrix;
    float4x4 projectionMatrix;
    float4x4 modelViewProjectionMatrix;
};

vertex xyzw_n_st_rgba textureTwoSidedMIOVertexShader(xyz_n_st in [[ stage_in ]], constant TransformPackage &transformPackage [[ buffer(1) ]]) {
    
    xyzw_n_st_rgba out;
    
    // xyzw
    out.xyzw = transformPackage.modelViewProjectionMatrix * float4(in.xyz, 1.0);
    
    // n
    out.n = in.n;
    
    // st
    out.st = in.st;
    
    // rgba
    out.rgba = half4(0,0,0,0);

    return out;

}

fragment float4 textureTwoSidedMIOFragmentShader(xyzw_n_st_rgba in [[stage_in]], bool isFrontFacing [[front_facing]], texture2d<float> front [[texture(0)]], texture2d<float> back [[texture(1)]]) {
    
    constexpr sampler defaultSampler;
    
    float4 rgba;
    
    if (isFrontFacing == true) {
        rgba = front.sample(defaultSampler, float2(in.st)).rgba;
    } else {
        rgba = back.sample(defaultSampler, float2(in.st)).rgba;
    }
    
    return rgba;
    
}
