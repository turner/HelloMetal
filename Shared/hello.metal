
#include <metal_stdlib>
using namespace metal;
#import "ei_common.h"
#import "metal.h"

vertex InterpolatedVertex show_st_vertex(constant _Vertex_ *vertices [[buffer(_attributes_)]], constant _Transforms_ &transforms [[buffer(_transform_)]], uint vertexIndex [[vertex_id]]) {
    InterpolatedVertex out;
    out.xyzw = transforms.modelViewProjectionMatrix * float4(vertices[vertexIndex].xyz, 1.0);
    out.rgba = vertices[vertexIndex].rgba;
    out.st = vertices[vertexIndex].st;
    return out;
}

fragment float4 show_st_fragment(InterpolatedVertex vert [[stage_in]]) {
    
    float4 s = float4(vert.st[0], 0, 0, 1);
    //    return s;
    
    float4 t = float4(0, vert.st[1], 0, 1);
    //    return t;
    
    float4 st = s + t;
    return st;
    
    //    return float4(.25, .25, .25, 1.0);
}

vertex InterpolatedVertex helloVertexShader(constant _Vertex_ *vertices [[buffer(_attributes_)]], constant _Transforms_ &transforms [[buffer(_transform_)]], uint vertexIndex [[vertex_id]]) {
    InterpolatedVertex out;
    out.xyzw = transforms.modelViewProjectionMatrix * float4(vertices[vertexIndex].xyz, 1.0);
    out.rgba = vertices[vertexIndex].rgba;
    return out;
}

fragment float4 helloFragmentShader(InterpolatedVertex vert [[stage_in]]) {
    return vert.rgba;
}

vertex InterpolatedVertex hello_texture_vertex(constant _Vertex_ *vertices [[ buffer(_attributes_) ]], constant _Transforms_ &transforms [[ buffer(_transform_) ]], uint vertexIndex [[ vertex_id ]]) {
    InterpolatedVertex out;
    
    out.xyzw = transforms.modelViewProjectionMatrix * float4(vertices[vertexIndex].xyz, 1.0);
    
    out.rgba = vertices[vertexIndex].rgba;
    
    out.st = vertices[vertexIndex].st;
    
    return out;
}

fragment float4 hello_texture_fragment(InterpolatedVertex vert [[ stage_in ]], texture2d<float>  texas [[ texture(0) ]], sampler textureSampler [[ sampler(0) ]]) {
    float4 rgba = texas.sample(textureSampler, vert.st).rgba;
    return rgba;
    
}
