//
//  EIMesh.swift
//  HelloMetal
//
//  Created by Douglass Turner on 10/23/16.
//  Copyright © 2016 Elastic Image Software. All rights reserved.
//

import ModelIO

import SceneKit
import SceneKit.ModelIO

import MetalKit
import MetalKit.MTKModel

import GLKit

class EIMesh {

    var metallicTransform: MetallicTransform

    var modelIOMeshMetallic: MDLMesh
    var mesh: MTKMesh
    
    var metalVertexDescriptor:MTLVertexDescriptor

    var submesh: MTKSubmesh {
        return mesh.submeshes[ 0 ]
    }

    var vertexMetalBuffer: MTLBuffer {
        return mesh.vertexBuffers[ 0 ].buffer
    }

    var vertexIndexMetalBuffer: MTLBuffer {
        return mesh.submeshes[ 0 ].indexBuffer.buffer
    }

    var primitiveType: MTLPrimitiveType {
        return mesh.submeshes[ 0 ].primitiveType
    }

    var indexCount: Int {
        return mesh.submeshes[ 0 ].indexCount
    }

    var indexType: MTLIndexType {
        return mesh.submeshes[ 0 ].indexType
    }

    init(device: MTLDevice, mdlMeshProvider:() -> MDLMesh) {

        metallicTransform = MetallicTransform(device:device)

        // Metal vertex descriptor
        metalVertexDescriptor = MTLVertexDescriptor.xyz_n_st_vertexDescriptor()

        // Model I/O vertex descriptor
        let modelIOVertexDescriptor = MTKModelIOVertexDescriptorFromMetal(metalVertexDescriptor)
        (modelIOVertexDescriptor.attributes[ 0 ] as! MDLVertexAttribute).name = MDLVertexAttributePosition
        (modelIOVertexDescriptor.attributes[ 1 ] as! MDLVertexAttribute).name = MDLVertexAttributeNormal
        (modelIOVertexDescriptor.attributes[ 2 ] as! MDLVertexAttribute).name = MDLVertexAttributeTextureCoordinate

        metalVertexDescriptor = MTLVertexDescriptor.xyz_n_st_vertexDescriptor()
        
        modelIOMeshMetallic = mdlMeshProvider()
        modelIOMeshMetallic.vertexDescriptor = modelIOVertexDescriptor

        do {
            mesh = try MTKMesh(mesh:modelIOMeshMetallic, device:device)
        } catch {
            fatalError("Error: Can not create Metal mesh")
        }

    }

    class func plane(device: MTLDevice,
                     xExtent:Float,
                     zExtent:Float,
                     xTesselation:UInt32,
                     zTesselation:UInt32) -> EIMesh {

        return EIMesh(device:device, mdlMeshProvider:{
            
            return MDLMesh.newPlane(withDimensions:vector_float2(xExtent, zExtent), segments:vector_uint2(xTesselation, zTesselation), geometryType:.triangles, allocator: MTKMeshBufferAllocator(device:device))

        })

    }

    class func cube(device: MTLDevice,
                    xExtent:Float,
                    yExtent:Float,
                    zExtent:Float,
                    xTesselation:UInt32,
                    yTesselation:UInt32,
                    zTesselation:UInt32) -> EIMesh {

        return EIMesh(device:device, mdlMeshProvider:{

            return MDLMesh.newBox(withDimensions: vector_float3(xExtent, yExtent, zExtent),
                    segments: vector_uint3(xTesselation, yTesselation, zTesselation),
                    geometryType: .triangles,
                    inwardNormals: false,
                    allocator: MTKMeshBufferAllocator(device: device))

        })

    }
    
    class func sphere(device: MTLDevice,
                      xRadius:Float,
                      yRadius:Float,
                      zRadius:Float,
                      uTesselation:Int,
                      vTesselation:Int) -> EIMesh {
        
        return EIMesh(device:device, mdlMeshProvider:{
            
            return MDLMesh.newEllipsoid(withRadii: vector_float3(xRadius, yRadius, zRadius),
                                        radialSegments: uTesselation,
                                        verticalSegments: vTesselation,
                                        geometryType: .triangles,
                                        inwardNormals: false,
                                        hemisphere: false,
                                        allocator: MTKMeshBufferAllocator(device: device))
            
        })
        
    }
    
    class func sceneMesh(device:MTLDevice, sceneName:String, nodeName:String) -> EIMesh {
        
        return EIMesh(device:device, mdlMeshProvider:{
            
            guard let scene = SCNScene(named:sceneName) else {
                fatalError("Error: Can not create SCNScene with \(sceneName)")
            }
            
            guard let sceneNode = scene.rootNode.childNode(withName:nodeName, recursively:true) else {
                fatalError("Error: Can not create sceneNode")
            }
            
            guard let sceneGeometry = sceneNode.geometry else {
                fatalError("Error: Can not create sceneGeometry")
            }
 
            let mdlm = MDLMesh(scnGeometry:sceneGeometry, bufferAllocator:nil)
            
            let mdlSubmesh:MDLSubmesh = mdlm.submeshes?[ 0 ] as! MDLSubmesh
            
            let mdlIndexBuffer:MDLMeshBuffer = mdlSubmesh.indexBuffer
            
            let mtlBuffer:MTLBuffer = device.makeBuffer(bytes:mdlIndexBuffer.map().bytes, length: mdlIndexBuffer.length, options:MTLResourceOptions.storageModeShared)

            return MDLMesh.newPlane(withDimensions:vector_float2(4, 4), segments:vector_uint2(2, 2), geometryType:.triangles, allocator: MTKMeshBufferAllocator(device:device))
            
        })
        
    }

}

class EIOneMeshToRuleThemAll {

    var metallicTransform: MetallicTransform

    var modelIOMeshMetallic: MDLMesh

    var mesh: MTKMesh

    var metalVertexDescriptor:MTLVertexDescriptor

    var vertexMetalBuffer: MTLBuffer

    var vertexIndexMetalBuffer: MTLBuffer

    var primitiveType: MTLPrimitiveType {
        return mesh.submeshes[ 0 ].primitiveType
    }

    var indexCount: Int {
        return /*mesh.submeshes[ 0 ].indexCount*/6
    }

    var indexType: MTLIndexType {
        return mesh.submeshes[ 0 ].indexType
    }

    init(device: MTLDevice, sceneName:String, nodeName:String) {

        metallicTransform = MetallicTransform(device:device)

        // Metal vertex descriptor
        metalVertexDescriptor = MTLVertexDescriptor.xyz_n_st_vertexDescriptor()

        // Model I/O vertex descriptor
        let modelIOVertexDescriptor = MTKModelIOVertexDescriptorFromMetal(metalVertexDescriptor)
        (modelIOVertexDescriptor.attributes[ 0 ] as! MDLVertexAttribute).name = MDLVertexAttributePosition
        (modelIOVertexDescriptor.attributes[ 1 ] as! MDLVertexAttribute).name = MDLVertexAttributeNormal
        (modelIOVertexDescriptor.attributes[ 2 ] as! MDLVertexAttribute).name = MDLVertexAttributeTextureCoordinate

        metalVertexDescriptor = MTLVertexDescriptor.xyz_n_st_vertexDescriptor()

        guard let scene = SCNScene(named:sceneName) else {
            fatalError("Error: Can not create SCNScene with \(sceneName)")
        }

        guard let sceneNode = scene.rootNode.childNode(withName:nodeName, recursively:true) else {
            fatalError("Error: Can not create sceneNode")
        }

        guard let sceneGeometry = sceneNode.geometry else {
            fatalError("Error: Can not create sceneGeometry")
        }

        var modelIOMesh = MDLMesh(scnGeometry:sceneGeometry, bufferAllocator:nil)
        modelIOMesh.vertexDescriptor = modelIOVertexDescriptor

        var mdlSubmesh:MDLSubmesh = modelIOMesh.submeshes?[ 0 ] as! MDLSubmesh

        var indexBuffer = mdlSubmesh.indexBuffer
        vertexIndexMetalBuffer = device.makeBuffer(bytes: indexBuffer.map().bytes, length: indexBuffer.length, options:MTLResourceOptions.storageModeShared)

        var vertexBuffer = modelIOMesh.vertexBuffers[ 0 ]
        vertexMetalBuffer = device.makeBuffer(bytes: vertexBuffer.map().bytes, length: vertexBuffer.length, options:MTLResourceOptions.storageModeShared)

        modelIOMeshMetallic = MDLMesh.newPlane(withDimensions:vector_float2(4, 4), segments:vector_uint2(2, 2), geometryType:.triangles, allocator: MTKMeshBufferAllocator(device:device))
        modelIOMeshMetallic.vertexDescriptor = modelIOVertexDescriptor

        do {
            mesh = try MTKMesh(mesh:modelIOMeshMetallic, device:device)
        } catch {
            fatalError("Error: Can not create Metal mesh")
        }

    }

}

/*
class EIMeshViaSceneKit : EIMesh {

    init(device:MTLDevice, sceneName:String, nodeName:String) {

        super.init(device:device, mdlMeshProvider: {

            guard let scene = SCNScene(named:sceneName) else {
                fatalError("Error: Can not create SCNScene with \(sceneName)")
            }

            guard let sceneNode = scene.rootNode.childNode(withName:nodeName, recursively:true) else {
                fatalError("Error: Can not create sceneNode")
            }

            guard let sceneGeometry = sceneNode.geometry else {
                fatalError("Error: Can not create sceneGeometry")
            }

            let mdlm = MDLMesh(scnGeometry:sceneGeometry, bufferAllocator: MTKMeshBufferAllocator(device: device))

            print("\(mdlm.vertexBuffers.first?.allocator is MTKMeshBufferAllocator)")

            return mdlm
        })

    }

}
*/

/*
typealias EISceneKitMesh = EIMesh

extension EISceneKitMesh {

    init(device:MTLDevice, sceneName:String, nodeName:String) {

        let metalVertexDescriptor = MTLVertexDescriptor.xyz_n_st_vertexDescriptor()

        let modelIOVertexDescriptor = MTKModelIOVertexDescriptorFromMetal(metalVertexDescriptor)
        (modelIOVertexDescriptor.attributes[ 0 ] as! MDLVertexAttribute).name = MDLVertexAttributePosition
        (modelIOVertexDescriptor.attributes[ 1 ] as! MDLVertexAttribute).name = MDLVertexAttributeNormal
        (modelIOVertexDescriptor.attributes[ 2 ] as! MDLVertexAttribute).name = MDLVertexAttributeTextureCoordinate

        metalMeshBufferAllocator = MTKMeshBufferAllocator(device:device)

        guard let scene = SCNScene(named:sceneName) else {
            fatalError("Error: Can not create SCNScene with \(sceneName)")
        }


        // TODO: Play with asset ... some day, sigh ...
        //        let asset = MDLAsset(scnScene:scene, bufferAllocator:MTKMeshBufferAllocator(device:device))


        /*

        Use with "MetalKit Essentials Using the MetalKit View TextureLoader and ModelIO" Apple demo
        approach. Sadly, ".scn" URLs not supported

        let asset = MDLAsset(url:objURL,
        vertexDescriptor:modelIOVertexDescriptor,
        bufferAllocator:metalMeshBufferAllocator)

        var metalMeshList:NSArray?
        var modelIOMeshList: NSArray?

        do {
        metalMeshList = try MTKMesh.newMeshes(from:asset, device:device, sourceMeshes:&modelIOMeshList) as NSArray?
        } catch let error as NSError {
        print(error.localizedDescription)
        }

        let bbox = asset.boundingBox
        print("bbox: \(bbox.minBounds.x) \(bbox.minBounds.y) \(bbox.minBounds.z)")
        print("bbox: \(bbox.maxBounds.x) \(bbox.maxBounds.y) \(bbox.maxBounds.z)")

        let kids = asset.childObjects(of:MDLMesh.self)

        let objModelIOMesh:MDLMesh = kids[ 0 ] as! MDLMesh

        objModelIOMesh.vertexDescriptor = modelIOVertexDescriptor
        */

        guard let sceneNode = scene.rootNode.childNode(withName:nodeName, recursively:true) else {
            fatalError("Error: Can not create sceneNode")
        }

        guard let sceneGeometry = sceneNode.geometry else {
            fatalError("Error: Can not create sceneGeometry")
        }

        //        modelIOMesh = MDLMesh(scnGeometry:sceneGeometry)
        //        modelIOMesh.vertexDescriptor = modelIOVertexDescriptor

        metallicModelIOMesh = MDLMesh(scnGeometry:sceneGeometry, bufferAllocator: MTKMeshBufferAllocator(device: device))
        metallicModelIOMesh.vertexDescriptor = modelIOVertexDescriptor

        // Always prints 'true'
        print("\(metallicModelIOMesh.vertexBuffers.first?.allocator is MTKMeshBufferAllocator)")

        do {
            mesh = try MTKMesh(mesh:metallicModelIOMesh, device:device)
        } catch let error as NSError {
            print(error.localizedDescription)
        }

    }

}
*/


