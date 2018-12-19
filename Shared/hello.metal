
#include <metal_stdlib>
using namespace metal;
#import "metal_common.h"

vertex InterpolatedVertex helloVertexShader(constant _Vertex_ *vertices [[buffer(0)]], constant _Transforms_ &transforms [[buffer(1)]], uint vertexIndex [[vertex_id]]) {
    InterpolatedVertex out;
    out.xyzw = transforms.modelViewProjectionMatrix * float4(vertices[vertexIndex].xyz, 1.0);
    out.rgba = vertices[vertexIndex].rgba;
    return out;
}

fragment float4 helloFragmentShader(InterpolatedVertex vert [[stage_in]]) {
    return vert.rgba;
}
