
#include <metal_stdlib>
using namespace metal;

struct xyz_n_st {
    float3 xyz [[ attribute(0) ]];
    float3 n   [[ attribute(1) ]];
    half2 st   [[ attribute(2) ]];
};

struct xyzw_n_st_rgba {
    float4 xyzw [[ position ]];
    float3 n;
    half2  st;
    half4  rgba;
};

struct TransformPackage {
    float3x3 normalMatrix;
    float4x4 modelMatrix;
    float4x4 viewMatrix;
    float4x4 modelViewMatrix;
    float4x4 modelViewProjectionMatrix;
};

//InterpolatedVertex out;
//
//out.xyzw = transforms.modelViewProjectionMatrix * float4(vertices[ vertexIndex ].xyz, 1.0);
//
//out.n = transforms.normalMatrix * vertices[ vertexIndex ].n;
//
//// in camera space
//float4 f4 = -(transforms.modelViewMatrix * float4(vertices[ vertexIndex ].xyz, 1.0));
//out.toEye = f4.xyz;
//
//out.rgba = vertices[ vertexIndex ].rgba;
//
//out.st = vertices[ vertexIndex ].st;
//
//return out;

vertex xyzw_n_st_rgba litTextureMIOVertexShader(xyz_n_st in [[ stage_in ]],
                                                constant TransformPackage &transformPackage [[ buffer(1) ]]) {
    
    xyzw_n_st_rgba out;
    
    // xyzw
    out.xyzw = transformPackage.modelViewProjectionMatrix * float4(in.xyz, 1.0);
    
    // n
//    out.n = transformPackage.normalMatrix * in.n;
    out.n = in.n;

    // st
    out.st = in.st;
    
    // rgba
    out.rgba = half4(1,0,0,1);

    return out;

}

fragment float4 litTextureMIOFragmentShader(xyzw_n_st_rgba in [[ stage_in ]],
                                            bool isFrontFacing [[ front_facing ]],
                                            texture2d<float> texas [[ texture(0 )]]) {
    
    constexpr sampler defaultSampler;
 
    float3 v = normalize(in.n);

    float4 rgba;
    
    if (isFrontFacing == true) {
        rgba = float4(v, 1);
//        rgba = texas.sample(defaultSampler, float2(in.st)).rgba;
    } else {
        rgba = float4(-v, 1);
//        rgba = float4(.5,.5,.5,1);
    }
    
    return rgba;
    
}

