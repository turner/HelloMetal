//
//  MTLRenderPipelineDescriptor+EIInit.swift
//  HelloMetal
//
//  Created by Douglass Turner on 12/13/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import MetalKit

extension MTLRenderPipelineDescriptor {
    
    class func EIInit(library:MTLLibrary, vertexShaderName:String, fragmentShaderName:String, sampleCount:Int, colorPixelFormat:MTLPixelFormat, vertexDescriptor:MTLVertexDescriptor?) -> MTLRenderPipelineDescriptor {
        
        let desc:MTLRenderPipelineDescriptor = MTLRenderPipelineDescriptor()
        
        guard let vert = library.makeFunction(name: vertexShaderName) else {
            fatalError("Error: Can not create vertex shader \(vertexShaderName)")
        }
        
        guard let frag = library.makeFunction(name: fragmentShaderName) else {
            fatalError("Error: Can not create fragment shader \(fragmentShaderName)")
        }
        
        desc.vertexFunction   = vert
        desc.fragmentFunction = frag
        
        desc.sampleCount = sampleCount
        
        desc.colorAttachments[ 0 ].pixelFormat = colorPixelFormat
        
        desc.colorAttachments[ 0 ].isBlendingEnabled = true
        
        desc.colorAttachments[ 0 ].rgbBlendOperation = .add
        desc.colorAttachments[ 0 ].alphaBlendOperation = .add
        
        desc.colorAttachments[ 0 ].sourceRGBBlendFactor = .one
        desc.colorAttachments[ 0 ].sourceAlphaBlendFactor = .one
        
        desc.colorAttachments[ 0 ].destinationRGBBlendFactor = .oneMinusSourceAlpha
        desc.colorAttachments[ 0 ].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        
        desc.depthAttachmentPixelFormat = .depth32Float
        
        if (nil != vertexDescriptor) {
            desc.vertexDescriptor = vertexDescriptor
        }
        
        return desc
    }
    
}
