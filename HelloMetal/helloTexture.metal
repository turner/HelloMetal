
#include <metal_stdlib>
using namespace metal;

struct _Vertex_ {
    float4 xyzw [[position]];
    float4 rgba;
    float2 st;
};

struct _Transforms_ {
    float4x4 modelMatrix;
    float4x4 viewMatrix;
    float4x4 projectionMatrix;
    float4x4 modelViewProjectionMatrix;
};

vertex _Vertex_ helloTextureVertexShader(
                                         constant _Vertex_ *vertices [[ buffer(0) ]],
                                         constant _Transforms_ &transforms [[ buffer(1) ]],
                                         uint vertexIndex [[ vertex_id ]]) {
    _Vertex_ out;
    out.xyzw = transforms.modelViewProjectionMatrix * float4(vertices[vertexIndex].xyzw);
    out.rgba = vertices[vertexIndex].rgba;
    out.st = vertices[vertexIndex].st;
    return out;
}

fragment float4 helloTextureFragmentShader(
                                           _Vertex_ vert [[ stage_in ]],
                                           texture2d<float> texas [[ texture(0) ]]
                                           ) {
    
    constexpr sampler defaultSampler;
    
//    float2 st_flipped = float2(vert.st[ 0 ], 1 - vert.st[ 1 ]);
//    float4 rgba = texas.sample(defaultSampler, st_flipped).rgba;
    
    float4 rgba = texas.sample(defaultSampler, vert.st).rgba;
    return rgba;
    
//    float4 s = float4(vert.st[0], 0, 0, 1);
//    float4 t = float4(0, vert.st[1], 0, 1)
//    float4 st = s + t;
//    return st;
    
//    float percent = 0.125;
//    return percent * rgba + (1 - percent) * st;
}
