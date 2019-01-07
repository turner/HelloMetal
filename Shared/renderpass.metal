
#include <metal_stdlib>
using namespace metal;
#import "ei_shader_share.h"
#import "metal_common.h"

vertex InterpolatedVertex renderpass_vertex(constant _Vertex_ *vertices [[buffer(_attributes_)]],
                                                constant _Transforms_ &transforms [[buffer(_transform_)]],
                                                uint vertexIndex [[vertex_id]]) {
    InterpolatedVertex out;
    out.xyzw = transforms.modelViewProjectionMatrix * float4(vertices[vertexIndex].xyz, 1.0);
    out.rgba = vertices[vertexIndex].rgba;
    out.st = vertices[vertexIndex].st;
    return out;
}

// pass through shader. just reproduce what is in the renderpass_texture
fragment float4 renderpass_fragment(InterpolatedVertex vert [[ stage_in ]], texture2d<float> renderpass_texture [[ texture(0) ]], sampler textureSampler [[sampler(0)]]) {
    return renderpass_texture.sample(textureSampler, vert.st).rgba;
}

fragment float4 renderpass_overlay_fragment(InterpolatedVertex vert [[ stage_in ]], texture2d<float> underlay [[ texture(0) ]], texture2d<float> overlay [[ texture(1) ]], sampler textureSampler [[sampler(0)]]) {

    float4 _F =  overlay.sample(textureSampler, vert.st).rgba;
    float4 _B = underlay.sample(textureSampler, vert.st).rgba;

    float4 rgba = _F + (1.0f - _F.a) * _B;

    return rgba;
}
