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
    
    /*
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
    */
    
}

class EIOneMeshToRuleThemAll {

    var metallicTransform:MetallicTransform
    
    var modelIOMesh:MDLMesh
    
    var modelIOMeshMetallic:MDLMesh

    var metalMesh:MTKMesh

    var metalVertexDescriptor:MTLVertexDescriptor

    var vertexMetalBuffer:MTLBuffer

    var vertexIndexMetalBuffer:MTLBuffer

    var indexCount:Int
    
    var primitiveType:MTLPrimitiveType

    var indexType:MTLIndexType

    init(device:MTLDevice, sceneName:String, nodeName:String) {

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

        modelIOMesh = MDLMesh(scnGeometry:sceneGeometry, bufferAllocator:nil)
        modelIOMesh.vertexDescriptor = modelIOVertexDescriptor

        let mdlSubmesh:MDLSubmesh = modelIOMesh.submeshes?[ 0 ] as! MDLSubmesh
 
        indexCount = mdlSubmesh.indexCount
        indexType = (.uInt32 == mdlSubmesh.indexType) ? .uint32 : .uint16;
        
        let indexBuffer = mdlSubmesh.indexBuffer
        vertexIndexMetalBuffer = device.makeBuffer(bytes:indexBuffer.map().bytes,
                                                   length:indexBuffer.length,
                                                   options:MTLResourceOptions.storageModeShared)

        let vertexBuffer = modelIOMesh.vertexBuffers[ 0 ]
        vertexMetalBuffer = device.makeBuffer(bytes:vertexBuffer.map().bytes,
                                              length:vertexBuffer.length,
                                              options:MTLResourceOptions.storageModeShared)

        modelIOMeshMetallic = MDLMesh.newPlane(withDimensions:vector_float2(4, 4),
                                               segments:vector_uint2(2, 2),
                                               geometryType:.triangles,
                                               allocator: MTKMeshBufferAllocator(device:device))
        
        modelIOMeshMetallic.vertexDescriptor = modelIOVertexDescriptor

        do {
            metalMesh = try MTKMesh(mesh:modelIOMeshMetallic, device:device)
        } catch {
            fatalError("Error: Can not create Metal mesh")
        }
        
        primitiveType = metalMesh.submeshes[ 0 ].primitiveType
//        indexType = metalMesh.submeshes[ 0 ].indexType
        
    }

}


