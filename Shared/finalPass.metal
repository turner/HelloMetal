
#include <metal_stdlib>
using namespace metal;

struct _Vertex_ {
    float4 xyzw [[position]]; // required
    float4 rgba;
    float2 st;
};

struct _Transforms_ {
    float4x4 modelMatrix;
    float4x4 viewMatrix;
    float4x4 projectionMatrix;
    float4x4 modelViewProjectionMatrix;
};

vertex _Vertex_ finalPassVertexShader(constant _Vertex_ *vertices [[buffer(0)]], constant _Transforms_ &transforms [[buffer(1)]], uint vertexIndex [[vertex_id]]) {
    _Vertex_ out;
    out.xyzw = transforms.modelViewProjectionMatrix * float4(vertices[vertexIndex].xyzw);
    out.rgba = vertices[vertexIndex].rgba;
    out.st = vertices[vertexIndex].st;
    return out;
}

fragment float4 finalPassFragmentShader(_Vertex_ vert [[ stage_in ]], texture2d<float> texas [[ texture(0) ]]) {
    
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
