
#include <metal_stdlib>
using namespace metal;

struct _Vertex_ {
    float3 xyz;
    float3 n;
    float4 rgba;
    float2 st;
};

struct InterpolatedVertex {
    float4 xyzw [[position]]; // required
    float4 rgba;
    float2 st;
};

struct _Transforms_ {
    float4x4 normalMatrix;
    float4x4 modelMatrix;
    float4x4 viewMatrix;
    float4x4 modelViewMatrix;
    float4x4 modelViewProjectionMatrix;
};

vertex InterpolatedVertex renderpass_vertex(constant _Vertex_ *vertices [[buffer(0)]],
                                                constant _Transforms_ &transforms [[buffer(1)]],
                                                uint vertexIndex [[vertex_id]]) {
    InterpolatedVertex out;
    out.xyzw = transforms.modelViewProjectionMatrix * float4(vertices[vertexIndex].xyz, 1.0);
    out.rgba = vertices[vertexIndex].rgba;
    out.st = vertices[vertexIndex].st;
    return out;
}

// a pass through shader. just reproduce what is in the renderpass_texture
fragment float4 renderpass_fragment(InterpolatedVertex vert [[ stage_in ]], texture2d<float> renderpass_texture [[ texture(0) ]], sampler textureSampler [[sampler(0)]]) {
    return renderpass_texture.sample(textureSampler, vert.st).rgba;
}

fragment float4 finalPassFragmentShader(InterpolatedVertex vert [[ stage_in ]],
                                        texture2d<float> texas [[ texture(0) ]]) {
    
    constexpr sampler defaultSampler;
    
    float4 rgba = texas.sample(defaultSampler, vert.st).rgba;
    
    // hack
    if (vert.st[0] < 0.5) {
        return rgba;
    } else {
        float _r = 1 - rgba.r/rgba.a;
        float _g = 1 - rgba.g/rgba.a;
        float _b = 1 - rgba.b/rgba.a;
        float4 cooked = float4(rgba.a * _r, rgba.a * _g, rgba.a * _b, rgba.a);
        return cooked;
    }
    
    //    return rgba;
}

fragment float4 renderpass_overlay_fragment(InterpolatedVertex vert [[ stage_in ]], texture2d<float> underlay [[ texture(0) ]], texture2d<float> overlay [[ texture(1) ]], sampler textureSampler [[sampler(0)]]) {

    float4 _F =  overlay.sample(textureSampler, vert.st).rgba;
    float4 _B = underlay.sample(textureSampler, vert.st).rgba;

    float4 rgba = _F + (1.0f - _F.a) * _B;

    return rgba;
}
