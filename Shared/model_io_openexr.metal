
#include <metal_stdlib>
using namespace metal;
#import "metal_model_io_common.h"

vertex xyzw_n_st_rgba openEXR_vertex(xyz_n_st in [[ stage_in ]], constant TransformPackage &transformPackage [[ buffer(1) ]]) {
    
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

fragment half4 openEXR_fragment(xyzw_n_st_rgba in [[ stage_in ]], texture2d<half> openEXRTexture [[ texture(0) ]], sampler textureSampler [[sampler(0)]]) {
    half4 rgba = openEXRTexture.sample(textureSampler, float2(in.st)).rgba;
    return rgba;
}
