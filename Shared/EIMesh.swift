//
//  EIMesh.swift
//  HelloMetal
//
//  Created by Douglass Turner on 10/23/16.
//  Copyright © 2016 Elastic Image Software. All rights reserved.
//

import ModelIO
import MetalKit

struct EIMesh {

    var mesh: MTKMesh!

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
        metalVertexDescriptor = MTLVertexDescriptor()
        
        // xyz
        metalVertexDescriptor.attributes[0].format = .float3
        metalVertexDescriptor.attributes[0].offset = 0
        metalVertexDescriptor.attributes[0].bufferIndex = 0
        
        // n
        metalVertexDescriptor.attributes[1].format = .float3
        metalVertexDescriptor.attributes[1].offset = 12
        metalVertexDescriptor.attributes[1].bufferIndex = 0
        
        // st
        metalVertexDescriptor.attributes[2].format = .half2
        metalVertexDescriptor.attributes[2].offset = 24
        metalVertexDescriptor.attributes[2].bufferIndex = 0
        
        // Single interleaved buffer.
        metalVertexDescriptor.layouts[0].stride = 28
        metalVertexDescriptor.layouts[0].stepRate = 1
        metalVertexDescriptor.layouts[0].stepFunction = .perVertex
        
        // Model I/O vertex descriptor
        let modelIOVertexDescriptor = MTKModelIOVertexDescriptorFromMetal(metalVertexDescriptor)
        (modelIOVertexDescriptor.attributes[ 0 ] as! MDLVertexAttribute).name = MDLVertexAttributePosition
        (modelIOVertexDescriptor.attributes[ 1 ] as! MDLVertexAttribute).name = MDLVertexAttributeNormal
        (modelIOVertexDescriptor.attributes[ 2 ] as! MDLVertexAttribute).name = MDLVertexAttributeTextureCoordinate

        return modelIOVertexDescriptor
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
            
            let mdlMesh = MDLMesh.newPlane(withDimensions: vector_float2(xExtent, yExtent),
                                           segments: vector_uint2(xTesselation, yTesselation),
                                           geometryType: .triangles,
                                           allocator: MTKMeshBufferAllocator(device: device))

            /*
            Setting this applies the new layout in 'vertexBuffers' thus is a
            heavyweight operation as structured copies of almost all vertex
            buffer data could be made.

            Additionally, if the new vertexDescriptor does not have an attribute in the original vertexDescriptor, that
            attribute will be deleted.  If the original vertexDescriptor does
            not have an attribute in the new vertexDescriptor, the data for the
            added attribute set as the added attribute's initializationValue
            property.

            The allocator associated with each original meshbuffer is used to
            reallocate the corresponding resultant meshbuffer.
            */
            mdlMesh.vertexDescriptor = initializationHelper(device: device)
            
            mesh = try MTKMesh(mesh: mdlMesh, device: device)
            
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


