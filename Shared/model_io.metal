
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
    float4x4 modelMatrix;
    float4x4 viewMatrix;
    float4x4 projectionMatrix;
    float4x4 modelViewProjectionMatrix;
};

vertex xyzw_n_st_rgba modelIOVertexShader(xyz_n_st in [[ stage_in ]], constant TransformPackage &transformPackage [[ buffer(1) ]]) {
    
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

fragment float4 modelIOFragmentShader(xyzw_n_st_rgba in [[ stage_in ]], texture2d<float> texas [[ texture(0) ]]) {
    
    constexpr sampler defaultSampler;
    
    float4 rgba = texas.sample(defaultSampler, float2(in.st)).rgba;
    
    return rgba;
    
}

vertex xyzw_n_st_rgba showMIOVertexShader(xyz_n_st in [[ stage_in ]], constant TransformPackage &transformPackage [[ buffer(1) ]]) {

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

fragment float4 showMIOFragmentShader(xyzw_n_st_rgba in [[ stage_in ]]) {

    float4 s = float4(in.st[0], 0, 0, 1);
//    return s;

    float4 t = float4(0, in.st[1], 0, 1);
//    return t;

    float4 st = s + t;
    return st;
}
