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

        self.transform = EISMatrix4MakeLookAt(eye:location, target: target, approximateUp: approximateUp)
//        let _blurb = "camera.transform"
//        self.transform.description(blurb:_blurb)

    }

    mutating func setProjection (fovYDegrees:Float, aspectRatioWidthOverHeight:Float, near:Float, far:Float) {

        self.fovYDegrees = fovYDegrees;
        self.near = near;
        self.far = far;
        self.aspectRatioWidthOverHeight = aspectRatioWidthOverHeight;

        self.projectionTransform = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(self.fovYDegrees), self.aspectRatioWidthOverHeight, self.near, self.far);
//        self.projectionTransform.description()

    }

}
