
#include <metal_stdlib>
using namespace metal;
#import "metal_common_model_io.h"

vertex xyzw_n_st_rgba textureMIOVertexShader(xyz_n_st in [[ stage_in ]], constant TransformPackage &transformPackage [[ buffer(1) ]]) {
    
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

fragment float4 textureMIOFragmentShader(xyzw_n_st_rgba in [[stage_in]], texture2d<float> texas [[texture(0)]], sampler textureSampler [[sampler(0)]]) {
    float4 rgba = texas.sample(textureSampler, float2(in.st)).rgba;
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
