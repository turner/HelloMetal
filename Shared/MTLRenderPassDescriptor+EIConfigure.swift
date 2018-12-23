//
//  MTLRenderPassDescriptor+EIConfigure.swift
//  HelloMetal
//
//  Created by Douglass Turner on 12/13/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import MetalKit
extension MTLRenderPassDescriptor {
    
    public func EIConfigure(clearColor:MTLClearColor, clearDepth: Double) {
        
        // color
        colorAttachments[ 0 ] = MTLRenderPassColorAttachmentDescriptor()
        colorAttachments[ 0 ].storeAction = .multisampleResolve
        colorAttachments[ 0 ].loadAction = .clear
        colorAttachments[ 0 ].clearColor = clearColor
        
        // depth
        depthAttachment = MTLRenderPassDepthAttachmentDescriptor()
        depthAttachment.storeAction = .dontCare
        depthAttachment.loadAction = .clear
        depthAttachment.clearDepth = clearDepth;
        
    }
    
    
}
