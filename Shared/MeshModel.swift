//
//  MeshModel.swift
//  HelloMetal
//
//  Created by Douglass Turner on 10/23/16.
//  Copyright © 2016 Elastic Image Software. All rights reserved.
//

import ModelIO
import MetalKit

struct EICube {

    var mdlMesh: MDLMesh!
    var mesh: MTKMesh!
    var submesh: MTKSubmesh!
    
    var vertexMetalBuffer: MTLBuffer!
    var vertexIndexMetalBuffer: MTLBuffer!
    var indexCount: Int!
    var indexType: MTLIndexType!
    var primitiveType: MTLPrimitiveType!

    var vertexDescriptor: MTLVertexDescriptor!

    var metallicTransform: MetallicTransform!

    init(device: MTLDevice, xExtent:Float, yExtent:Float, zExtent:Float, xTesselation:UInt32, yTesselation:UInt32, zTesselation:UInt32) {

        let allocator = MTKMeshBufferAllocator(device: device)
        
        mdlMesh = MDLMesh(boxWithExtent: vector_float3(xExtent, yExtent, zExtent),
                              segments: vector_uint3(xTesselation, yTesselation, zTesselation),
                              inwardNormals: false,
                              geometryType: .triangles,
                              allocator: allocator)

        do {
            self.mesh = try MTKMesh(mesh: self.mdlMesh, device: device)
        } catch {
            fatalError("Error: Can not create mesh")
        }

        self.metallicTransform = MetallicTransform(device: device)

        // Get a reference to the first submesh of the mesh
        self.submesh = self.mesh.submeshes[ 0 ]

        // Extract the vertex buffer for the whole mesh
        self.vertexMetalBuffer = self.mesh.vertexBuffers[ 0 ].buffer

        // Extract the index buffer of the submesh
        self.vertexIndexMetalBuffer = self.submesh.indexBuffer.buffer

        // Get the primitive type of the mesh (triangle, triangle strip, etc.)
        self.primitiveType = self.submesh.primitiveType

        // Get the number of indices for this submesh
        self.indexCount = self.submesh.indexCount

        // Get the type of the indices (16-bit or 32-bit uints)
        self.indexType = self.submesh.indexType

    }

}


