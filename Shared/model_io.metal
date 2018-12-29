
#include <metal_stdlib>
using namespace metal;
#import "metal_model_io_common.h"

vertex xyzw_n_st_rgba model_io_show_vertex(xyz_n_st in [[ stage_in ]], constant TransformPackage &transformPackage [[ buffer(1) ]]) {
    
    xyzw_n_st_rgba out;
    
    // eye space normal
    float4 nes = transformPackage.normalMatrix * float4(in.n, 1);
    float3 normalEyeSpace = normalize(nes.xyz);
    
    // world space normal
//    float3 in_n = normalize(in.n);
    
    // rgba
    //    out.rgba = float4(in.st.x, in.st.y, 0, 1);
    //    out.rgba = float4(in_n, 1.0);
    out.rgba = float4((normalEyeSpace.x + 1.0)/2.0, (normalEyeSpace.y + 1.0)/2.0, (normalEyeSpace.z + 1.0)/2.0, 1.0);
    
    // xyzw
    out.xyzw = transformPackage.modelViewProjectionMatrix * float4(in.xyz, 1);
    
    // st
    out.st = in.st;
    
    return out;
    
}

fragment float4 model_io_show_fragment(xyzw_n_st_rgba in [[ stage_in ]]) {
    
    constexpr sampler defaultSampler;
    
    float4 rgba;
    
    rgba = in.rgba;
    
    return rgba;
    
}

vertex xyzw_n_st_rgba model_io_texture_vertex(xyz_n_st in [[ stage_in ]], constant TransformPackage &transformPackage [[ buffer(1) ]]) {
    
    xyzw_n_st_rgba out;
    
    // xyzw
    out.xyzw = transformPackage.modelViewProjectionMatrix * float4(in.xyz, 1.0);
    
    // n
    out.n = in.n;
    
    // st
    out.st = in.st;
    
    // rgba
    out.rgba = float4(0,0,0,0);
    
    return out;
    
}

fragment float4 model_io_texture_fragment(xyzw_n_st_rgba in [[stage_in]], texture2d<float> texas [[texture(0)]], sampler textureSampler [[sampler(0)]]) {
    float4 rgba = texas.sample(textureSampler, float2(in.st)).rgba;
    return rgba;
}

vertex xyzw_n_st_rgba model_io_texture_lit_vertex(xyz_n_st in [[ stage_in ]], constant TransformPackage &transformPackage [[ buffer(1) ]]) {
    
    
    // light at camera location. Flashlight style.
    float3 lightPosition = float3(0, 0, 1500);
    float3 lightPositionEyeSpace = (transformPackage.viewMatrix * float4(lightPosition, 1)).xyz;
    
    float4 f4 = float4(in.n, 1);
    float4 nes = transformPackage.normalMatrix * f4;
    //    float4 nes = f4;
    
    float3 f3 = nes.xyz;
    float3 normalEyeSpace = normalize(f3);
    
    float3 diffuseColor = float3(1, 1, 1);
    
    float NdotL = max(0.0f, dot(normalEyeSpace, normalize(lightPositionEyeSpace)));
    float3 diffuseColorNdotL = diffuseColor * NdotL;
    
    xyzw_n_st_rgba out;
    
    // rgba
    //    out.rgba = float4(normalEyeSpace, 1);
    out.rgba = float4(diffuseColorNdotL, 1);
    
    // xyzw
    out.xyzw = transformPackage.modelViewProjectionMatrix * float4(in.xyz, 1);
    
    // n
    out.n = normalEyeSpace;
    
    // st
    out.st = in.st;
    
    return out;
    
}

fragment float4 model_io_texture_lit_fragment(xyzw_n_st_rgba in [[stage_in]], texture2d<float> texas [[texture(0)]], sampler textureSampler [[sampler(0)]]) {
    float4 rgba;
    rgba = in.rgba * texas.sample(textureSampler, float2(in.st)).rgba;
    return rgba;
}

vertex xyzw_n_st_rgba textureTwoSidedMIOVertexShader(xyz_n_st in [[ stage_in ]], constant TransformPackage &transformPackage [[ buffer(1) ]]) {
    
    xyzw_n_st_rgba out;
    
    // xyzw
    out.xyzw = transformPackage.modelViewProjectionMatrix * float4(in.xyz, 1.0);
    
    // n
    out.n = in.n;
    
    // st
    out.st = in.st;
    
    // rgba
    out.rgba = float4(0,0,0,0);

    return out;

}

fragment float4 textureTwoSidedMIOFragmentShader(xyzw_n_st_rgba in [[stage_in]], bool isFrontFacing [[front_facing]], texture2d<float> front [[texture(0)]], texture2d<float> back [[texture(1)]], sampler textureSampler [[sampler(0)]]) {

    float4 rgba;
    
    if (isFrontFacing == true) {
        rgba = front.sample(textureSampler, float2(in.st)).rgba;
    } else {
        rgba = back.sample(textureSampler, float2(in.st)).rgba;
    }
    
    return rgba;
    
}
