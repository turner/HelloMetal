
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
    float4  rgba;
    half2  st;
};

struct TransformPackage {
    float4x4 normalMatrix;
    float4x4 modelMatrix;
    float4x4 viewMatrix;
    float4x4 modelViewMatrix;
    float4x4 modelViewProjectionMatrix;
};

vertex xyzw_n_st_rgba litTextureMIOVertexShader(xyz_n_st in [[ stage_in ]],
                                                constant TransformPackage &transformPackage [[ buffer(1) ]]) {
 
    
    // light at camera location. Flashlight style.
    float3 lightPosition = float3(0, 0, 1500);
    float3 lightPositionEyeSpace = (transformPackage.viewMatrix * float4(lightPosition, 1)).xyz;
    
    float4x4 _normal_matrix_ = transformPackage.normalMatrix;

    float4 f4 = float4(in.n, 1);
    float4 nes = _normal_matrix_ * f4;
    float3 f3 = nes.xyz;
    
    float3 normalEyeSpace = normalize( f3 );

    float3 diffuseColor = float3(1, 1, 1);
    
    float NdotL = max(0.0f, dot(normalEyeSpace, normalize(lightPositionEyeSpace)));
    float3 diffuseColorNdotL = diffuseColor * NdotL;
    
    xyzw_n_st_rgba out;
    
    // rgba
//    out.rgba = float4(normalEyeSpace, 1);
    out.rgba = float4(diffuseColorNdotL, 1);
    
    // xyzw
    out.xyzw = transformPackage.modelViewProjectionMatrix * float4(in.xyz, 1);
    
    // n
    out.n = normalEyeSpace;

    // st
    out.st = in.st;

    return out;

}

fragment float4 litTextureMIOFragmentShader(xyzw_n_st_rgba in [[ stage_in ]],
                                            bool isFrontFacing [[ front_facing ]],
                                            texture2d<float> texas [[ texture(0 )]]) {
    
    constexpr sampler defaultSampler;
    
    float4 rgba;
    
//    rgba = in.rgba;
    rgba = in.rgba * texas.sample(defaultSampler, float2(in.st)).rgba;
    
    return rgba;
    
}

/*
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
*/

