
#include <metal_stdlib>
using namespace metal;

struct _Vertex_ {
    float4 xyzw [[position]]; // required
    float4 rgba;
    float2 st;
};

struct _Transforms_ {
    float3x3 normalMatrix;
    float4x4 modelMatrix;
    float4x4 viewMatrix;
    float4x4 projectionMatrix;
    float4x4 modelViewProjectionMatrix;
};

vertex _Vertex_ helloVertexShader(constant _Vertex_ *vertices [[buffer(0)]], constant _Transforms_ &transforms [[buffer(1)]], uint vertexIndex [[vertex_id]]) {
    _Vertex_ out;
    out.xyzw = transforms.modelViewProjectionMatrix * float4(vertices[vertexIndex].xyzw);
    out.rgba = vertices[vertexIndex].rgba;
    return out;
}

fragment float4 helloFragmentShader(_Vertex_ vert [[stage_in]]) {
    return vert.rgba;
}
