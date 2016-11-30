
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
    float3x3 normalMatrix;
    float4x4 modelMatrix;
    float4x4 viewMatrix;
    float4x4 projectionMatrix;
    float4x4 modelViewProjectionMatrix;
};

vertex InterpolatedVertex litTextureVertexShader(constant _Vertex_ *vertices [[ buffer(0) ]],
                                       constant _Transforms_ &transforms [[ buffer(1) ]],
                                       uint vertexIndex [[ vertex_id ]]) {
    InterpolatedVertex out;
    out.xyzw = transforms.modelViewProjectionMatrix * float4(vertices[vertexIndex].xyz, 1.0);
    
    out.rgba = vertices[vertexIndex].rgba;
    
    out.st = vertices[vertexIndex].st;
    
    return out;
}

fragment float4 litTextureFragmentShader(InterpolatedVertex vert [[ stage_in ]],
                                         texture2d<float> texas [[ texture(0) ]]) {
    
    constexpr sampler defaultSampler;
    
    float4 rgba = texas.sample(defaultSampler, vert.st).rgba;
    return rgba;
    
//    float3 rgb = float3(rgba.r/rgba.a, rgba.g/rgba.a, rgba.b/rgba.a);
//    return float4(rgb.r * vert.rgba.r, rgb.g * vert.rgba.g, rgb.b * vert.rgba.b, rgba.a);
    
}
