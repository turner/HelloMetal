
#include <metal_stdlib>
using namespace metal;
#import "metal_common_model_io.h"

vertex xyzw_n_st_rgba model_io_show_vertex(xyz_n_st in [[ stage_in ]], constant TransformPackage &transformPackage [[ buffer(1) ]]) {
 
    xyzw_n_st_rgba out;
    
    // eye space normal
    float4 nes = transformPackage.normalMatrix * float4(in.n, 1);
    float3 normalEyeSpace = normalize(nes.xyz);
    
    // world space normal
    float3 in_n = normalize(in.n);
    
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
