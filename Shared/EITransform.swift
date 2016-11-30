//
//  EITransform.swift
//  HelloMetal
//
//  Created by Douglass Turner on 9/11/16.
//  Copyright © 2016 Elastic Image Software. All rights reserved.
//

import Metal
import GLKit

struct Transform {

    var normalMatrix = GLKMatrix3Identity
    var modelMatrix = GLKMatrix4Identity
    var viewMatrix = GLKMatrix4Identity
    var projectionMatrix = GLKMatrix4Identity
    var modelViewProjectionMatrix = GLKMatrix4Identity
    
    init() {
        normalMatrix = GLKMatrix3Identity
        modelMatrix = GLKMatrix4Identity
        viewMatrix = GLKMatrix4Identity
        projectionMatrix = GLKMatrix4Identity
        modelViewProjectionMatrix = GLKMatrix4Identity
    }
    
    init(mvp: GLKMatrix4) {
        normalMatrix = GLKMatrix3Identity
        modelMatrix = GLKMatrix4Identity
        viewMatrix = GLKMatrix4Identity
        projectionMatrix = GLKMatrix4Identity
        modelViewProjectionMatrix = mvp
    }
}

struct EITransform {
    var transform = Transform()
    var metalBuffer: MTLBuffer

    init(device: MTLDevice) {
        metalBuffer = device.makeBuffer(length: MemoryLayout<Transform>.size, options: [])
    }
    
    init(mvp: GLKMatrix4, device: MTLDevice) {
        transform = Transform(mvp: mvp)
        metalBuffer = device.makeBuffer(length: MemoryLayout<Transform>.size, options: [])
    }

    mutating func update () {
        let bufferPointer = metalBuffer.contents()
        memcpy(bufferPointer, &transform, MemoryLayout<Transform>.size)
    }

    mutating func update (camera: EICamera, transformer:() -> GLKMatrix4) {
        transform.modelMatrix = transformer()
        transform.modelViewProjectionMatrix = camera.projectionTransform * camera.transform * transform.modelMatrix
        update()
    }
}
