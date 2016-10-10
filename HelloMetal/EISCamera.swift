//
//  EISCamera.swift
//  HelloMetal
//
//  Created by Douglass Turner on 9/16/16.
//  Copyright © 2016 Elastic Image Software. All rights reserved.
//

import GLKit

struct EISCamera {

    var location: GLKVector3!
    var target: GLKVector3!
    var transform: GLKMatrix4!
    var projectionTransform: GLKMatrix4!

    var near: Float!
    var far: Float!

    var fovYDegrees: Float!
    var aspectRatioWidthOverHeight: Float!

    mutating func setTransform (location:GLKVector3, target:GLKVector3, approximateUp:GLKVector3) {

        self.location = location
        self.target = target

        self.transform = makeLookAt(eye:location, target: target, approximateUp: approximateUp)
    }

    mutating func setProjection (fovYDegrees:Float, aspectRatioWidthOverHeight:Float, near:Float, far:Float) {

        self.fovYDegrees = fovYDegrees;
        self.near = near;
        self.far = far;
        self.aspectRatioWidthOverHeight = aspectRatioWidthOverHeight;

        self.projectionTransform = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(self.fovYDegrees), self.aspectRatioWidthOverHeight, self.near, self.far);

    }

    func makeLookAt(eye:GLKVector3, target:GLKVector3, approximateUp:GLKVector3) -> GLKMatrix4 {

        let n = GLKVector3Normalize(GLKVector3Add(eye, GLKVector3Negate(target)))

        var crossed:GLKVector3!

        crossed = GLKVector3CrossProduct(approximateUp, n)
        var u:GLKVector3!
        if (GLKVector3Length(crossed) > 0.0001) {
            u = GLKVector3Normalize(crossed)
        } else {
            u = crossed
        }

        crossed = GLKVector3CrossProduct(n, u)
        var v:GLKVector3!
        if (GLKVector3Length(crossed) > 0.0001) {
            v = GLKVector3Normalize(crossed)
        } else {
            v = crossed
        }

        let m = GLKMatrix4(m: (
                u.x, v.x, n.x, Float(0),
                u.y, v.y, n.y, Float(0),
                u.z, v.z, n.z, Float(0),
                GLKVector3DotProduct(GLKVector3Negate(u), eye), GLKVector3DotProduct(GLKVector3Negate(v), eye), GLKVector3DotProduct(GLKVector3Negate(n), eye), Float(1)))

        return m;
    }


}
