
#include <metal_stdlib>
using namespace metal;
#import "ei_common.h"
#import "metal_model_io.h"

vertex xyzw_n_st_rgba renderpass_vertex(xyz_n_st in [[ stage_in ]], constant _Transforms_ &transformPackage [[ buffer(_transform_) ]]) {

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

// pass through shader. just reproduce what is in the renderpass_texture
fragment float4 renderpass_fragment(xyzw_n_st_rgba in [[stage_in]], texture2d<float> texas [[texture(0)]], sampler textureSampler [[sampler(0)]]) {
    return texas.sample(textureSampler, float2(in.st)).rgba;
}

fragment float4 renderpass_overlay_fragment(xyzw_n_st_rgba in [[stage_in]], texture2d<float> underlay [[ texture(0) ]], texture2d<float> overlay [[ texture(1) ]], sampler textureSampler [[sampler(0)]]) {

    float4 _F =  overlay.sample(textureSampler, float2(in.st)).rgba;
    float4 _B = underlay.sample(textureSampler, float2(in.st)).rgba;

    float4 rgba = _F + (1.0f - _F.a) * _B;

    return rgba;
}
