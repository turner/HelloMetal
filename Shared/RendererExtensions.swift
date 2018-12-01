//
//  RendererExtensions.swift
//  HelloMetal
//
//  Created by Douglass Turner on 10/21/16.
//  Copyright © 2016 Elastic Image Software. All rights reserved.
//

import MetalKit

extension MTLSamplerDescriptor {

    class func EI_CreateMipMapSamplerState(device:MTLDevice) -> MTLSamplerState? {

        let samplerDescriptor = MTLSamplerDescriptor()

        // texture coordinate 0..1
        samplerDescriptor.normalizedCoordinates = true

        // bi-linear mipmap filtering
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.mipFilter = .linear

        return device.makeSamplerState(descriptor: samplerDescriptor)

    }
}

extension MTLRenderCommandEncoder {

    func EI_Configure(renderPipelineState:MTLRenderPipelineState, model:EIModelProtocol, textures:[MTLTexture]) {

        self.setRenderPipelineState(renderPipelineState)

        self.setVertexBuffer(model.getVertexMetalBuffer(), offset: 0, index: 0)
        self.setVertexBuffer(model.getMetallicTransformMetalBuffer(), offset: 0, index: 1)

        for i in 0..<textures.count {
            let texture = textures[ i ]
            self.setFragmentTexture(texture, index: i)
        }

        self.drawIndexedPrimitives(type: model.getPrimitiveType(), indexCount: model.getIndexCount(), indexType: model.getIndexType(), indexBuffer: model.getIndexBuffer(), indexBufferOffset: 0)
    }

}

extension MTLRenderPipelineDescriptor {

    class func EI_Create(library:MTLLibrary, vertexShaderName:String, fragmentShaderName:String, sampleCount:Int, colorPixelFormat:MTLPixelFormat, vertexDescriptor:MTLVertexDescriptor?) -> MTLRenderPipelineDescriptor {

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

    convenience init(library:MTLLibrary, vertexShaderName:String, fragmentShaderName:String, sampleCount:Int, colorPixelFormat:MTLPixelFormat, vertexDescriptor:MTLVertexDescriptor?) {

        self.init()

        vertexFunction   = library.makeFunction(name: vertexShaderName)
        fragmentFunction = library.makeFunction(name: fragmentShaderName)

        self.sampleCount = sampleCount

        colorAttachments[ 0 ].pixelFormat = colorPixelFormat

        colorAttachments[ 0 ].isBlendingEnabled = true

        colorAttachments[ 0 ].rgbBlendOperation = .add
        colorAttachments[ 0 ].alphaBlendOperation = .add

        colorAttachments[ 0 ].sourceRGBBlendFactor = .one
        colorAttachments[ 0 ].sourceAlphaBlendFactor = .one

        colorAttachments[ 0 ].destinationRGBBlendFactor = .oneMinusSourceAlpha
        colorAttachments[ 0 ].destinationAlphaBlendFactor = .oneMinusSourceAlpha

        depthAttachmentPixelFormat = .depth32Float

        if (nil != vertexDescriptor) {
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

    public func EI_configure(clearColor:MTLClearColor, clearDepth: Double) {

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

    public func EI_renderpass_configure(clearColor:MTLClearColor, clearDepth: Double) {

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

