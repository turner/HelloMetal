//
//  RenderPassRenderer.swift
//  HelloMetal
//
//  Created by Douglass Turner on 9/11/16.
//  Copyright © 2016 Elastic Image Software. All rights reserved.
//
import ModelIO
import MetalKit
import GLKit

class LightRenderer: NSObject, MTKViewDelegate {

    var camera:EICamera!

    var model: EIMesh!
    var texture: MTLTexture!
    var pipelineState: MTLRenderPipelineState!

    var cameraPlane: EIMesh!
    var cameraPlaneTexture: MTLTexture!
    var cameraPlanePipelineState: MTLRenderPipelineState!

    let depthStencilState: MTLDepthStencilState?
    let samplerState: MTLSamplerState?
    let commandQueue: MTLCommandQueue?

    init(view: MTKView, device: MTLDevice) {

        guard let ss = MTLSamplerDescriptor.EI_CreateMipMapSamplerState(device: device) else {
            fatalError("Error: Can not create sampler state")
        }

        samplerState = ss

        guard let cq = device.makeCommandQueue() else {
            fatalError("Error: Can not create command queue")
        }

        commandQueue = cq

        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = true

        guard let dss = device.makeDepthStencilState(descriptor: depthStencilDescriptor) else {
            fatalError("Error: Can not create depth stencil state")
        }

        depthStencilState = dss
    }

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        reshape(view:view as! EIView)
    }

    func reshape (view: EIView) {
        view.arcBall.reshape(viewBounds: view.bounds)
        camera.setProjection(fovYDegrees:Float(35), aspectRatioWidthOverHeight:Float(view.bounds.size.width / view.bounds.size.height), near: 100, far: 8000)
    }

    func update(view: EIView, drawableSize:CGSize) {
        
        // render plane
        cameraPlane.metallicTransform.update(camera: camera, transformer: {
            return camera.createRenderPlaneTransform(distanceFromCamera: 0.75 * camera.far) * GLKMatrix4MakeRotation(GLKMathDegreesToRadians(90), 1, 0, 0)
        })

        // hero model
        model.metallicTransform.update(camera: camera, transformer: {

            // typical return value
//            return view.arcBall.rotationMatrix
            
            // scaling for high res head
            return view.arcBall.rotationMatrix * GLKMatrix4MakeScale(500, 500, 500) * GLKMatrix4MakeTranslation(0.0, 0.075, 0.101)
            
            // scaling for teapot
//            return view.arcBall.rotationMatrix * GLKMatrix4MakeScale(250, 250, 250)
        })

    }

    public func draw(in view: MTKView) {

        update(view: view as! EIView, drawableSize: view.bounds.size)

        if let passDescriptor = view.currentRenderPassDescriptor, let drawable = view.currentDrawable {

            guard let buffer = commandQueue!.makeCommandBuffer() else {
                fatalError("Error: Can not create command buffer")
            }

            guard let encoder = buffer.makeRenderCommandEncoder(descriptor: passDescriptor) else {
                fatalError("Error: Can not create command encoder")
            }

            encoder.setDepthStencilState(depthStencilState)

            encoder.setFrontFacing(.counterClockwise)
            encoder.setTriangleFillMode(.fill)
            encoder.setCullMode(.none)
            encoder.setFragmentSamplerState(samplerState, index: 0)

            // camera plane
            encoder.EI_Configure(renderPipelineState: cameraPlanePipelineState, model: cameraPlane, textures: [cameraPlaneTexture])

            // hero model
            encoder.EI_Configure(renderPipelineState: pipelineState, model: self.model, textures: [texture])

            encoder.endEncoding()

            buffer.present(drawable)
            buffer.commit()
        }

    }

}
