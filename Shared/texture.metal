
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

vertex InterpolatedVertex hello_texture_vertex(constant _Vertex_       *vertices [[ buffer(0) ]],
                                              constant _Transforms_ &transforms [[ buffer(1) ]],
                                              uint                  vertexIndex [[ vertex_id ]]) {
    InterpolatedVertex out;
    
    out.xyzw = transforms.modelViewProjectionMatrix * float4(vertices[vertexIndex].xyz, 1.0);
    
    out.rgba = vertices[vertexIndex].rgba;
    
    out.st = vertices[vertexIndex].st;
    
    return out;
}

fragment float4 hello_texture_fragment(InterpolatedVertex vert [[ stage_in   ]], texture2d<float>  texas [[ texture(0) ]], sampler textureSampler [[sampler(0)]]) {
    float4 rgba = texas.sample(textureSampler, vert.st).rgba;
    return rgba;

}
