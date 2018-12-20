//
//  EIShader.swift
//  HelloMetal
//
//  Created by Douglass Turner on 12/7/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import MetalKit
struct EIShader {
    
    var pipelineState:MTLRenderPipelineState
    var textures: [MTLTexture] = [MTLTexture]()

    init(view:EIView, library: MTLLibrary, vertex:String, fragment:String, textures:[MTLTexture], vertexDescriptor:MTLVertexDescriptor?) {

        for i in 0..<textures.count {
            self.textures.append(textures[ i ])
        }

        let pipelineDescriptor =
                MTLRenderPipelineDescriptor.EI_Create(library:library, vertexShaderName:vertex, fragmentShaderName:fragment, sampleCount:view.sampleCount, colorPixelFormat:view.colorPixelFormat, vertexDescriptor:vertexDescriptor)
        do {
            pipelineState = try view.device!.makeRenderPipelineState(descriptor:pipelineDescriptor)
        } catch {
            fatalError("Error: Can not create render pipeline state")
        }

    }

    init(view:EIView, library: MTLLibrary, vertex:String, fragment:String, textureNames:[String], vertexDescriptor:MTLVertexDescriptor?) {

        for i in 0..<textureNames.count {
            textures.append(MTKTextureLoader.newTexture_UIImage(device: view.device!, name: textureNames[i]))
        }

        let pipelineDescriptor =
                MTLRenderPipelineDescriptor.EI_Create(library:library, vertexShaderName:vertex, fragmentShaderName:fragment, sampleCount:view.sampleCount, colorPixelFormat:view.colorPixelFormat, vertexDescriptor:vertexDescriptor)
        do {
            pipelineState = try view.device!.makeRenderPipelineState(descriptor:pipelineDescriptor)
        } catch {
            fatalError("Error: Can not create render pipeline state")
        }

    }
}
