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
    var normalMatrix = GLKMatrix4Identity
    var modelMatrix = GLKMatrix4Identity
    var viewMatrix = GLKMatrix4Identity
    var modelViewMatrix = GLKMatrix4Identity
    var modelViewProjectionMatrix = GLKMatrix4Identity
}

struct EITransform {
    var transform = Transform()
    var metalBuffer: MTLBuffer

    init(device: MTLDevice) {
        guard let mb = device.makeBuffer(length: MemoryLayout<Transform>.size, options: []) else {
            fatalError("Error: Can not create buffer for EITransform")
        }
        
        metalBuffer = mb
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

        // eye space normal transform is the inverse( transpose( model-view-transform ) )
        // invert then transpose upper 3x3
        var success = false
        let m3x3 = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3( transform.modelViewMatrix ), &success)
        
        // stuff into 4x4 to match metal shader TransformerPackage struct.
//        transform.normalMatrix = GLKMatrix4Identity
        transform.normalMatrix = GLKMatrix4Make(m3x3.m00, m3x3.m01, m3x3.m02, 0,
                                                m3x3.m10, m3x3.m11, m3x3.m12, 0,
                                                m3x3.m20, m3x3.m21, m3x3.m22, 0,
                                                       0,        0,        0, 1)

        let bufferPointer = metalBuffer.contents()
        memcpy(bufferPointer, &transform, MemoryLayout<Transform>.size)

    }
}
