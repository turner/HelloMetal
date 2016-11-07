//
//  RendererExtensions.swift
//  HelloMetal
//
//  Created by Douglass Turner on 10/21/16.
//  Copyright © 2016 Elastic Image Software. All rights reserved.
//

import MetalKit


extension MTLVertexDescriptor {
    
    class func xyz_n_st_vertexDescriptor() -> MTLVertexDescriptor {
        
        // Metal vertex descriptor
        let vertexDescriptor = MTLVertexDescriptor()
        
        // xyz
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        // n
        vertexDescriptor.attributes[1].format = .float3
        vertexDescriptor.attributes[1].offset = 12
        vertexDescriptor.attributes[1].bufferIndex = 0
        
        // st
        vertexDescriptor.attributes[2].format = .half2
        vertexDescriptor.attributes[2].offset = 24
        vertexDescriptor.attributes[2].bufferIndex = 0
        
        // Single interleaved buffer.
        vertexDescriptor.layouts[0].stride = 28
        vertexDescriptor.layouts[0].stepRate = 1
        vertexDescriptor.layouts[0].stepFunction = .perVertex

        return vertexDescriptor

    }
}




extension MTLRenderPipelineDescriptor {
    
    convenience init(view: MTKView,
                     library: MTLLibrary,
                     vertexShaderName:String,
                     fragmentShaderName:String,
                     doIncludeDepthAttachment:Bool,
                     vertexDescriptor:MTLVertexDescriptor?) {
        
        self.init()
        
        vertexFunction = library.makeFunction(name: vertexShaderName)
        fragmentFunction = library.makeFunction(name: fragmentShaderName)
        
        colorAttachments[ 0 ].pixelFormat = view.colorPixelFormat
        
        colorAttachments[ 0 ].isBlendingEnabled = true
        
        colorAttachments[ 0 ].rgbBlendOperation = .add
        colorAttachments[ 0 ].alphaBlendOperation = .add
        
        colorAttachments[ 0 ].sourceRGBBlendFactor = .one
        colorAttachments[ 0 ].sourceAlphaBlendFactor = .one
        
        colorAttachments[ 0 ].destinationRGBBlendFactor = .oneMinusSourceAlpha
        colorAttachments[ 0 ].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        
        if (doIncludeDepthAttachment == true) {
            depthAttachmentPixelFormat = .depth32Float
        }
        
        if (vertexDescriptor != nil) {
            self.vertexDescriptor = vertexDescriptor
        }

    }

}


extension MTLRenderPassDescriptor {
    
    convenience init(clearColor:MTLClearColor, clearDepth: Double) {
        
        self.init()
        
        // color
        colorAttachments[ 0 ] = MTLRenderPassColorAttachmentDescriptor()
        colorAttachments[ 0 ].storeAction = .store
        colorAttachments[ 0 ].loadAction = .clear
        colorAttachments[ 0 ].clearColor = clearColor
        
        // depth
        depthAttachment = MTLRenderPassDepthAttachmentDescriptor()
        depthAttachment.storeAction = .dontCare
        depthAttachment.loadAction = .clear
        depthAttachment.clearDepth = clearDepth;
        
    }
    
}

