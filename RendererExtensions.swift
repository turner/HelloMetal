//
//  RendererExtensions.swift
//  HelloMetal
//
//  Created by Douglass Turner on 10/21/16.
//  Copyright © 2016 Elastic Image Software. All rights reserved.
//

import MetalKit

extension MTLRenderPipelineDescriptor {
    
    convenience init(view: MTKView, library: MTLLibrary, vertexShaderName:String, fragmentShaderName:String, doIncludeDepthAttachment:Bool) {
        
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

