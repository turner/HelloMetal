//
//  EIShader+EIOpenEXRTexture.swift
//  HelloOpenEXR
//
//  Created by Douglass Turner on 12/12/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import Metal
extension EIShader {
    
    init(view:EIView, library: MTLLibrary, vertex:String, fragment:String, openEXRTexture:EIOpenEXRTexture, vertexDescriptor:MTLVertexDescriptor?) {
        
        textures = [openEXRTexture.texture]
        
        let pipelineDescriptor =
            MTLRenderPipelineDescriptor.EI_Create(library:library, vertexShaderName:vertex, fragmentShaderName:fragment, sampleCount:view.sampleCount, colorPixelFormat:view.colorPixelFormat, vertexDescriptor:vertexDescriptor)
        do {
            pipelineState = try view.device!.makeRenderPipelineState(descriptor:pipelineDescriptor)
        } catch {
            fatalError("Error: Can not load texture")
        }
        
    }
}
