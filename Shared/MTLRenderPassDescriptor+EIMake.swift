//
//  MTLRenderPassDescriptor+EIMake.swift.swift
//  HelloMetal
//
//  Created by Douglass Turner on 12/13/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import MetalKit
extension MTLRenderPassDescriptor {

    public class func EIMake(clearColor:MTLClearColor, clearDepth: Double) -> MTLRenderPassDescriptor {

        let renderPassDescriptor = MTLRenderPassDescriptor()

        // color
        renderPassDescriptor.colorAttachments[ 0 ] = MTLRenderPassColorAttachmentDescriptor()
        renderPassDescriptor.colorAttachments[ 0 ].storeAction = .multisampleResolve
        renderPassDescriptor.colorAttachments[ 0 ].loadAction = .clear
        renderPassDescriptor.colorAttachments[ 0 ].clearColor = clearColor

        // depth
        renderPassDescriptor.depthAttachment = MTLRenderPassDepthAttachmentDescriptor()
        renderPassDescriptor.depthAttachment.storeAction = .dontCare
        renderPassDescriptor.depthAttachment.loadAction = .clear
        renderPassDescriptor.depthAttachment.clearDepth = clearDepth;

        return renderPassDescriptor
    }
    
}
