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

    /*
        Cheat Sheet

        // PVM = P * V * M
        GLKMatrix4 projectionViewModelTransform =
        GLKMatrix4Multiply(camera.projectionTransform, GLKMatrix4Multiply(camera.transform, modelTransform));

        // NormalTransform = Transpose( Inverse(V * M))
        GLKMatrix3 normalTransform =
        GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(GLKMatrix4Multiply(camera.transform, modelTransform)), NULL);

        // Single light source at camera. Flashlight mode.
        GLKVector3 lightPosition = camera.location;

        // transform light from world space to eye space
        GLKVector3 lightPositionEyeSpace = GLKMatrix3MultiplyVector3(GLKMatrix4GetMatrix3(camera.transform), lightPosition);

    */

    mutating func update (camera: EICamera, transformer:() -> GLKMatrix4) {
        transform.modelMatrix = transformer()
        transform.modelViewProjectionMatrix = camera.projectionTransform * camera.transform * transform.modelMatrix
        
        var success:Bool = false
        transform.normalMatrix = GLKMatrix3InvertAndTranspose( GLKMatrix4GetMatrix3( camera.transform * transform.modelMatrix ), &success)
//        print("is invertible \(success)" )
        update()
    }
}
