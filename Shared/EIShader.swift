//
//  EIShader.swift
//  HelloMetal
//
//  Created by Douglass Turner on 12/7/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import Metal
struct EIShader {
    
    var pipelineState:MTLRenderPipelineState
    var textures = [MTLTexture]()
    
    init(view:EIView, library: MTLLibrary, vertex:String, fragment:String, textureNames:[String], vertexDescriptor:MTLVertexDescriptor?) {
        
        for i in 0..<textureNames.count {
            do {
                let texture = try makeTexture(device: view.device!, name: textureNames[ i ])
                textures.append(texture)
            } catch {
                fatalError("Error: Can not load texture")
            }
        }
        
        let pipelineDescriptor =
            MTLRenderPipelineDescriptor.EI_Create(library:library, vertexShaderName:vertex, fragmentShaderName:fragment, sampleCount:view.sampleCount, colorPixelFormat:view.colorPixelFormat, vertexDescriptor:vertexDescriptor)
        do {
            pipelineState = try view.device!.makeRenderPipelineState(descriptor:pipelineDescriptor)
        } catch {
            fatalError("Error: Can not load texture")
        }
        
    }
}
