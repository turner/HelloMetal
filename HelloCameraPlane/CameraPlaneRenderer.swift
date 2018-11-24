//
//  RenderPassRenderer.swift
//  HelloMetal
//
//  Created by Douglass Turner on 9/11/16.
//  Copyright © 2016 Elastic Image Software. All rights reserved.
//

import MetalKit
import GLKit

class CameraPlaneRenderer: NSObject, MTKViewDelegate {

    var camera: EICamera!

    // hero model
    var heroModel: EIQuad!
    var heroTexture: MTLTexture!
    var heroPipelineState: MTLRenderPipelineState!

    var cameraPlane: EIQuad!
    var cameraPlaneTexture: MTLTexture!
    var cameraPlanePipelineState: MTLRenderPipelineState!

    var commandQueue: MTLCommandQueue?

    init(view: MTKView, device: MTLDevice) {

        guard let library = device.makeDefaultLibrary() else {
            fatalError("Error: Can not create default library")
        }

        do {

            let pipelineDescriptor =
                    MTLRenderPipelineDescriptor(library:library, vertexShaderName:"textureVertexShader", fragmentShaderName:"textureFragmentShader", sampleCount:view.sampleCount, colorPixelFormat:view.colorPixelFormat, vertexDescriptor: nil)

            heroPipelineState = try device.makeRenderPipelineState(descriptor:pipelineDescriptor)
        } catch let e {
            Swift.print("\(e)")
        }

        do {

            let pipelineDescriptor =
                    MTLRenderPipelineDescriptor(library:library, vertexShaderName:"textureVertexShader", fragmentShaderName:"textureFragmentShader", sampleCount:view.sampleCount, colorPixelFormat:view.colorPixelFormat, vertexDescriptor: nil)

            cameraPlanePipelineState = try device.makeRenderPipelineState(descriptor:pipelineDescriptor)
        } catch let e {
            Swift.print("\(e)")
        }

        guard let cq = device.makeCommandQueue() else {
            fatalError("Error: Can not create command queue")
        }

        commandQueue = cq
    }

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        reshape(view:view as! EIView)
    }

    func reshape (view: EIView) {
        view.arcBall.reshape(viewBounds: view.bounds)
        camera.setProjection(fovYDegrees:Float(35), aspectRatioWidthOverHeight:Float(view.bounds.size.width / view.bounds.size.height), near: 200, far: 8000)
    }

    func update(view: EIView, drawableSize:CGSize) {

        // render plane
        cameraPlane.metallicTransform.update(camera: camera, transformer: {
            return camera.createRenderPlaneTransform(distanceFromCamera: 0.75 * camera.far)
        })

        // hero model
        heroModel.metallicTransform.update(camera: camera, transformer: {
            return view.arcBall.rotationMatrix * GLKMatrix4MakeScale(150, 150, 1)
        })
        
    }

    public func draw(in view: MTKView) {

        update(view: view as! EIView, drawableSize: view.bounds.size)

        // final pass
        if let passDescriptor = view.currentRenderPassDescriptor, let drawable = view.currentDrawable {

            guard let buffer = commandQueue!.makeCommandBuffer() else {
                fatalError("Error: Can not create command buffer")
            }

            guard let encoder = buffer.makeRenderCommandEncoder(descriptor: passDescriptor) else {
                fatalError("Error: Can not create command encoder")
            }

            encoder.setFrontFacing(.counterClockwise)
            encoder.setTriangleFillMode(.fill)
            encoder.setCullMode(.none)

            // render plane
            encoder.EI_configure(renderPipelineState: cameraPlanePipelineState, model: cameraPlane, texture: cameraPlaneTexture)

            // hero model
            encoder.EI_configure(renderPipelineState: heroPipelineState, model: heroModel, texture: heroTexture)

            encoder.endEncoding()

            buffer.present(drawable)
            buffer.commit()
        }

    }

}
