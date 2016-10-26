//
//  MultiPassRenderer.swift
//  HelloMetal
//
//  Created by Douglass Turner on 9/11/16.
//  Copyright © 2016 Elastic Image Software. All rights reserved.
//

import MetalKit
import GLKit

class HelloModel_IORenderer: NSObject, MTKViewDelegate {

    var camera: EICamera!

    // hero model
    var heroModel: EICube!
    var heroModelTexture: MTLTexture!
    var heroModelPipelineState: MTLRenderPipelineState!

    var renderPlane: MetallicQuadModel!
    var renderPlaneTexture: MTLTexture!
    var renderPlanePipelineState: MTLRenderPipelineState!

    var commandQueue: MTLCommandQueue!

    init(view: MTKView, device: MTLDevice) {

        let library = device.newDefaultLibrary()

        camera = EICamera(location:GLKVector3(v:(0, 0, 1000)), target:GLKVector3(v:(0, 0, 0)), approximateUp:GLKVector3(v:(0, 1, 0)))


        // hero model
        heroModel = EICube(device: device, xExtent: 200, yExtent: 200, zExtent: 200, xTesselation: 16, yTesselation: 16, zTesselation: 16)

        do {
            heroModelTexture = try makeTexture(device: device, name: "candycane_disk")
        } catch {
            fatalError("Error: Can not load texture")
        }

        do {

            heroModelPipelineState =
                    try device.makeRenderPipelineState(descriptor:
                    MTLRenderPipelineDescriptor(view:view,
                            library:library!,
                            vertexShaderName:"textureMIOVertexShader",
                            fragmentShaderName:"textureMIOFragmentShader",
//                            vertexShaderName:"showMIOVertexShader",
//                            fragmentShaderName:"showMIOFragmentShader",
                            doIncludeDepthAttachment: false,
                            vertexDescriptor:heroModel.metalVertexDescriptor))
        } catch let e {
            Swift.print("\(e)")
        }


        // render plane
        renderPlane = MetallicQuadModel(device: device)

        do {

            let textureLoader = MTKTextureLoader(device: device)

            guard let image = UIImage(named:"diagnostic") else {
                fatalError("Error: Can not create UIImage")
            }

            if (image.cgImage?.alphaInfo == .premultipliedLast) {
                print("texture uses premultiplied alpha. Rock.")
            }

            let textureLoaderOptions:[String:NSNumber] = [ MTKTextureLoaderOptionSRGB:false ]

            renderPlaneTexture = try textureLoader.newTexture(with: image.cgImage!, options: textureLoaderOptions)
        } catch {
            fatalError("Error: Can not load texture")
        }

        do {

            renderPlanePipelineState =
                    try device.makeRenderPipelineState(descriptor:
                    MTLRenderPipelineDescriptor(view:view,
                            library:library!,
                            vertexShaderName:"textureVertexShader",
                            fragmentShaderName:"textureFragmentShader",
                            doIncludeDepthAttachment: false,
                            vertexDescriptor: nil))

        } catch let e {
            Swift.print("\(e)")
        }

        commandQueue = device.makeCommandQueue()

    }

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        reshape(view:view as! HelloModel_IOMetalView)
    }

    func reshape (view: HelloModel_IOMetalView) {
        view.arcBall.reshape(viewBounds: view.bounds)
        camera.setProjection(fovYDegrees:Float(35), aspectRatioWidthOverHeight:Float(view.bounds.size.width / view.bounds.size.height), near: 200, far: 8000)
    }

    func update(view: HelloModel_IOMetalView, drawableSize:CGSize) {

        // render plane
        renderPlane.metallicTransform.update(camera: camera, transformer: {
            return camera.createRenderPlaneTransform(distanceFromCamera: 0.75 * camera.far)
        })

        // hero model
        heroModel.metallicTransform.update(camera: camera, transformer: {
            return view.arcBall.rotationMatrix
        })

    }

    public func draw(in view: MTKView) {

        update(view: view as! HelloModel_IOMetalView, drawableSize: view.bounds.size)

        // final pass
        if let finalPassDescriptor = view.currentRenderPassDescriptor, let drawable = view.currentDrawable {

            let commandBuffer = commandQueue.makeCommandBuffer()

            let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: finalPassDescriptor)

            renderCommandEncoder.setFrontFacing(.counterClockwise)
            renderCommandEncoder.setCullMode(.none)

            // render plane
            renderCommandEncoder.setTriangleFillMode(.fill)

            renderCommandEncoder.setRenderPipelineState(renderPlanePipelineState)
            renderCommandEncoder.setVertexBuffer(renderPlane.vertexMetalBuffer, offset: 0, at: 0)
            renderCommandEncoder.setVertexBuffer(renderPlane.metallicTransform.metalBuffer, offset: 0, at: 1)
            renderCommandEncoder.setFragmentTexture(renderPlaneTexture, at: 0)
            renderCommandEncoder.drawIndexedPrimitives(
                    type: .triangle,
                    indexCount: renderPlane.vertexIndexMetalBuffer.length / MemoryLayout<UInt16>.size,
                    indexType: MTLIndexType.uint16,
                    indexBuffer: renderPlane.vertexIndexMetalBuffer,
                    indexBufferOffset: 0)

            // hero model
            renderCommandEncoder.setTriangleFillMode(.fill)

            renderCommandEncoder.setRenderPipelineState(heroModelPipelineState)
            renderCommandEncoder.setVertexBuffer(heroModel.vertexMetalBuffer, offset: 0, at: 0)
            renderCommandEncoder.setVertexBuffer(heroModel.metallicTransform.metalBuffer, offset: 0, at: 1)
            renderCommandEncoder.setFragmentTexture(heroModelTexture, at: 0)
            renderCommandEncoder.drawIndexedPrimitives(
                    type: heroModel.primitiveType,
                    indexCount: Int(heroModel.indexCount),
                    indexType: heroModel.indexType,
                    indexBuffer: heroModel.vertexIndexMetalBuffer,
                    indexBufferOffset: 0)

            renderCommandEncoder.endEncoding()

            commandBuffer.present(drawable)
            commandBuffer.commit()
        }

    }

}
