
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

vertex xyzw_n_st_rgba showMIOVertexShader(xyz_n_st in [[ stage_in ]],
                                                constant TransformPackage &transformPackage [[ buffer(1) ]]) {
 
    xyzw_n_st_rgba out;
    
    // rgba
    out.rgba = float4(in.st.x, in.st.y, 0, 1);
    
    // xyzw
    out.xyzw = transformPackage.modelViewProjectionMatrix * float4(in.xyz, 1);
    
    // st
    out.st = in.st;

    return out;

}

fragment float4 showMIOFragmentShader(xyzw_n_st_rgba in [[ stage_in ]],
                                            bool isFrontFacing [[ front_facing ]],
                                            texture2d<float> texas [[ texture(0 )]]) {
    
    constexpr sampler defaultSampler;
    
    float4 rgba;
    
    rgba = in.rgba;
    
    return rgba;
    
}
