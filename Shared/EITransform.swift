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
    var modelViewMatrix = GLKMatrix4Identity
    var modelViewProjectionMatrix = GLKMatrix4Identity
}

struct EITransform {
    var transform = Transform()
    var metalBuffer: MTLBuffer

    init(device: MTLDevice) {
        metalBuffer = device.makeBuffer(length: MemoryLayout<Transform>.size, options: [])
    }

    mutating func update () {
        let bufferPointer = metalBuffer.contents()
        memcpy(bufferPointer, &transform, MemoryLayout<Transform>.size)
    }

    /*
        Transform Cheat Sheet
        ---------------------
     
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

        //  M
        transform.modelMatrix = transformer()
        //  V
        transform.viewMatrix = camera.viewTransform
        //  V * M
        transform.modelViewMatrix = transform.viewMatrix * transform.modelMatrix
        //  P * V * M
        transform.modelViewProjectionMatrix = camera.projectionTransform * transform.modelViewMatrix
        
        var success:Bool
        
        success = false
        transform.normalMatrix = GLKMatrix3InvertAndTranspose( GLKMatrix4GetMatrix3( transform.modelViewMatrix ), &success)
                
        update()
    }
}
