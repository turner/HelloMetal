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

    var camera: EICamera

    var heroModel: EIMesh
    var heroModelTexture: MTLTexture
    var heroModelPipelineState: MTLRenderPipelineState!

    var renderPlane: EIMesh
    var renderPlaneTexture: MTLTexture
    var renderPlanePipelineState: MTLRenderPipelineState!
    
    var depthStencilState: MTLDepthStencilState

    var commandQueue: MTLCommandQueue

    init(view: MTKView, device: MTLDevice) {

        let library = device.newDefaultLibrary()
                        
        camera = EICamera(location:GLKVector3(v:(0, 0, 500)), target:GLKVector3(v:(0, 0, 0)), approximateUp:GLKVector3(v:(0, 1, 0)))

//        heroModel = EIMesh.plane(device: device, xExtent: 200, zExtent: 200, xTesselation: 2, zTesselation: 2)
        
        heroModel = EIMesh.sceneMesh(device:device,
                                     sceneName:"scenes.scnassets/high-res-head-no-groups.scn",
                                     nodeName:"highResHeadIdentity")
        
//        heroModel = EIMesh.sceneMesh(device:device,
//                                     sceneName:"scenes.scnassets/teapot.scn",
//                                     nodeName:"teapotIdentity")
        
//        heroModel = EIMesh.sceneMesh(device:device,
//                                     sceneName:"scenes.scnassets/better_male_head.scn",
//                                     nodeName:"betterHeadIdentity")
        
        do {
            heroModelTexture = try makeTexture(device: device, name: "swirl")
        } catch {
            fatalError("Error: Can not load texture")
        }

        do {
            heroModelPipelineState =
                    try device.makeRenderPipelineState(descriptor:MTLRenderPipelineDescriptor(view:view,
                            library:library!,
                            
//                            vertexShaderName:"litTextureMIOVertexShader",
//                            fragmentShaderName:"litTextureMIOFragmentShader",
                        
                            vertexShaderName:"showMIOVertexShader",
                            fragmentShaderName:"showMIOFragmentShader",

                            doIncludeDepthAttachment: false,
                            vertexDescriptor:heroModel.metalVertexDescriptor))
        } catch let e {
            Swift.print("\(e)")
        }

        // render plane
        renderPlane = EIMesh.plane(device:device, xExtent:2, zExtent:2, xTesselation:4, zTesselation:4)

        do {
            renderPlaneTexture = try makeTexture(device: device, name: "mobile")
        } catch {
            fatalError("Error: Can not load texture")
        }

        do {
            renderPlanePipelineState =
                    try device.makeRenderPipelineState(descriptor:
                    MTLRenderPipelineDescriptor(view:view,
                            library:library!,
                            vertexShaderName:"textureMIOVertexShader",
                            fragmentShaderName:"textureMIOFragmentShader",
                            doIncludeDepthAttachment: false,
                            vertexDescriptor: renderPlane.metalVertexDescriptor))

        } catch let e {
            Swift.print("\(e)")
        }

        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = true
        
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)
        
        commandQueue = device.makeCommandQueue()

    }

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        reshape(view:view as! LightView)
    }

    func reshape (view: LightView) {
        view.arcBall.reshape(viewBounds: view.bounds)
        camera.setProjection(fovYDegrees:Float(35), aspectRatioWidthOverHeight:Float(view.bounds.size.width / view.bounds.size.height), near: 100, far: 8000)
    }

    func update(view: LightView, drawableSize:CGSize) {
        
        // render plane
        renderPlane.metallicTransform.update(camera: camera, transformer: {
            return camera.createRenderPlaneTransform(distanceFromCamera: 0.75 * camera.far) * GLKMatrix4MakeRotation(GLKMathDegreesToRadians(90), 1, 0, 0)
        })

        // hero model
        heroModel.metallicTransform.update(camera: camera, transformer: {

            // typical return value
//            return view.arcBall.rotationMatrix
            
            // scaling for high res head
            return view.arcBall.rotationMatrix * GLKMatrix4MakeScale(600, 600, 600)
            
            // scaling for teapot
//            return view.arcBall.rotationMatrix * GLKMatrix4MakeScale(250, 250, 250)
        })

    }

    public func draw(in view: MTKView) {

        update(view: view as! LightView, drawableSize: view.bounds.size)

        // final pass
        if let finalPassDescriptor = view.currentRenderPassDescriptor, let drawable = view.currentDrawable {

            let commandBuffer = commandQueue.makeCommandBuffer()

            let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: finalPassDescriptor)
            
            renderCommandEncoder.setDepthStencilState(depthStencilState)
            
            renderCommandEncoder.setFrontFacing(.counterClockwise)
            renderCommandEncoder.setCullMode(.none)

            
            
            
            
            // render plane
            renderCommandEncoder.setTriangleFillMode(.fill)

            renderCommandEncoder.setRenderPipelineState(renderPlanePipelineState)

            renderCommandEncoder.setVertexBuffer(renderPlane.vertexMetalBuffer, offset: 0, at: 0)
            renderCommandEncoder.setVertexBuffer(renderPlane.metallicTransform.metalBuffer, offset: 0, at: 1)

            renderCommandEncoder.setFragmentTexture(renderPlaneTexture, at: 0)

            renderCommandEncoder.drawIndexedPrimitives(
                    type: renderPlane.primitiveType,
                    indexCount: renderPlane.indexCount,
                    indexType: renderPlane.indexType,
                    indexBuffer: renderPlane.vertexIndexMetalBuffer,
                    indexBufferOffset: 0)



            

            // hero model
            renderCommandEncoder.setTriangleFillMode(.fill)
//            renderCommandEncoder.setTriangleFillMode(.lines)

            renderCommandEncoder.setRenderPipelineState(heroModelPipelineState)

            renderCommandEncoder.setVertexBuffer(heroModel.vertexMetalBuffer, offset: 0, at: 0)
            renderCommandEncoder.setVertexBuffer(heroModel.metallicTransform.metalBuffer, offset: 0, at: 1)

            renderCommandEncoder.setFragmentTexture(heroModelTexture, at: 0)

            renderCommandEncoder.drawIndexedPrimitives(
                    type: heroModel.primitiveType,
                    indexCount: heroModel.indexCount,
                    indexType: heroModel.indexType,
                    indexBuffer: heroModel.vertexIndexMetalBuffer,
                    indexBufferOffset: 0)

            
            
            
            
            renderCommandEncoder.endEncoding()

            commandBuffer.present(drawable)
            commandBuffer.commit()
        }

    }

}
