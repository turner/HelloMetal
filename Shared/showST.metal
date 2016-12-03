
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

vertex InterpolatedVertex showSTVertexShader(constant _Vertex_ *vertices [[buffer(0)]],
                                   constant _Transforms_ &transforms [[buffer(1)]],
                                   uint vertexIndex [[vertex_id]]) {
    InterpolatedVertex out;
    out.xyzw = transforms.modelViewProjectionMatrix * float4(vertices[vertexIndex].xyz, 1.0);
    out.rgba = vertices[vertexIndex].rgba;
    out.st = vertices[vertexIndex].st;
    return out;
}

fragment float4 showSTFragmentShader(InterpolatedVertex vert [[stage_in]]) {
    
    float4 s = float4(vert.st[0], 0, 0, 1);
//    return s;
    
    float4 t = float4(0, vert.st[1], 0, 1);
//    return t;
    
    float4 st = s + t;
    return st;
    
//    return float4(.25, .25, .25, 1.0);
}
