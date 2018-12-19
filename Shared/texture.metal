
#include <metal_stdlib>
using namespace metal;
#import "metal_common.h"

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
