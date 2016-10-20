//
//  MetallicTransform.swift
//  HelloMetal
//
//  Created by Douglass Turner on 9/11/16.
//  Copyright © 2016 Elastic Image Software. All rights reserved.
//

import Metal
import GLKit

struct Transform {

    var modelMatrix: GLKMatrix4
    var viewMatrix: GLKMatrix4
    var projectionMatrix: GLKMatrix4
    var modelViewProjectionMatrix: GLKMatrix4

    init() {
        self.modelMatrix = GLKMatrix4Identity
        self.viewMatrix = GLKMatrix4Identity
        self.projectionMatrix = GLKMatrix4Identity
        self.modelViewProjectionMatrix = GLKMatrix4Identity
    }

    init(mvp: GLKMatrix4) {
        self.modelMatrix = GLKMatrix4Identity
        self.viewMatrix = GLKMatrix4Identity
        self.projectionMatrix = GLKMatrix4Identity
        self.modelViewProjectionMatrix = mvp
    }
}

struct MetallicTransform {
    var transform: Transform!
    var metalBuffer: MTLBuffer!

    init(device: MTLDevice) {
        self.transform = Transform()
        self.metalBuffer = device.makeBuffer(length: MemoryLayout<Transform>.size, options: [])
    }
    
    init(mvp: GLKMatrix4, device: MTLDevice) {
        self.transform = Transform(mvp: mvp)
        self.metalBuffer = device.makeBuffer(length: MemoryLayout<Transform>.size, options: [])
    }

    mutating func update () {

        let bufferPointer = self.metalBuffer.contents()
        memcpy(bufferPointer, &self.transform, MemoryLayout<Transform>.size)

    }
}
