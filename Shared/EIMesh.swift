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

struct EIMesh {

    var mesh: MTKMesh!
    var metalMeshBufferAllocator: MTKMeshBufferAllocator!

    var metallicModelIOMesh:MDLMesh!
    var modelIOMesh:MDLMesh!
    
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

    var metalVertexDescriptor: MTLVertexDescriptor!

    var metallicTransform: MetallicTransform!

    mutating func initializationHelper (device: MTLDevice)  -> MDLVertexDescriptor {
        
        metallicTransform = MetallicTransform(device: device)
        
        // Metal vertex descriptor
        metalVertexDescriptor = MTLVertexDescriptor.xyz_n_st_vertexDescriptor()
        
        // Model I/O vertex descriptor
        let modelIOVertexDescriptor = MTKModelIOVertexDescriptorFromMetal(metalVertexDescriptor)
        (modelIOVertexDescriptor.attributes[ 0 ] as! MDLVertexAttribute).name = MDLVertexAttributePosition
        (modelIOVertexDescriptor.attributes[ 1 ] as! MDLVertexAttribute).name = MDLVertexAttributeNormal
        (modelIOVertexDescriptor.attributes[ 2 ] as! MDLVertexAttribute).name = MDLVertexAttributeTextureCoordinate

        return modelIOVertexDescriptor
    }

}

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
        
        /*
        var asset = MDLAsset(scnScene:scene)
        var kids = asset.childObjects(of:MDLMesh.self)
        var mioMesh:MDLMesh = kids[ 0 ] as! MDLMesh
        mioMesh.vertexDescriptor = modelIOVertexDescriptor
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
        
        print("\(metallicModelIOMesh.vertexBuffers.first?.allocator is MTKMeshBufferAllocator)")

        do {
            mesh = try MTKMesh(mesh:metallicModelIOMesh, device:device)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
    }

}

typealias EIPlane = EIMesh

extension EIPlane {

    init(device: MTLDevice,
         xExtent:Float,
         yExtent:Float,
         xTesselation:UInt32,
         yTesselation:UInt32) {

        do {
            
            modelIOMesh = MDLMesh.newPlane(withDimensions: vector_float2(xExtent, yExtent),
                                                   segments: vector_uint2(xTesselation, yTesselation),
                                                   geometryType: .triangles,
                                                   allocator: nil)
            
            modelIOMesh.vertexDescriptor = initializationHelper(device: device)
           
            metallicModelIOMesh = MDLMesh.newPlane(withDimensions: vector_float2(xExtent, yExtent),
                                                   segments: vector_uint2(xTesselation, yTesselation),
                                                   geometryType: .triangles,
                                                   allocator: MTKMeshBufferAllocator(device: device))

            metallicModelIOMesh.vertexDescriptor = initializationHelper(device: device)

            mesh = try MTKMesh(mesh: metallicModelIOMesh, device: device)

        } catch {
            fatalError("Error: Can not create Metal mesh")
        }

    }

}

typealias EICube = EIMesh

extension EICube {
    
    init(device: MTLDevice,
         xExtent:Float,
         yExtent:Float,
         zExtent:Float,
         xTesselation:UInt32,
         yTesselation:UInt32,
         zTesselation:UInt32) {
        
        do {
            
            let mdlMesh = MDLMesh.newBox(withDimensions: vector_float3(xExtent, yExtent, zExtent),
                                         segments: vector_uint3(xTesselation, yTesselation, zTesselation),
                                         geometryType: .triangles,
                                         inwardNormals: false,
                                         allocator: MTKMeshBufferAllocator(device: device))
            
            mdlMesh.vertexDescriptor = initializationHelper(device: device)
            
            mesh = try MTKMesh(mesh: mdlMesh, device: device)
            
        } catch {
            fatalError("Error: Can not create Metal mesh")
        }
        
    }
    
}

typealias EISphere = EIMesh

extension EISphere {
    
    init(device: MTLDevice,
         xExtent:Float,
         yExtent:Float,
         zExtent:Float,
         uTesselation:Int,
         vTesselation:Int) {
        
        do {
            
            let mdlMesh = MDLMesh.newEllipsoid(withRadii: vector_float3(xExtent, yExtent, zExtent),
                                               radialSegments: uTesselation,
                                               verticalSegments: vTesselation,
                                               geometryType: .triangles,
                                               inwardNormals: false,
                                               hemisphere: false,
                                               allocator: MTKMeshBufferAllocator(device: device))
            
        
            mdlMesh.vertexDescriptor = initializationHelper(device: device)
            
            mesh = try MTKMesh(mesh: mdlMesh, device: device)
            
        } catch {
            fatalError("Error: Can not create Metal mesh")
        }
        
    }
    
}


