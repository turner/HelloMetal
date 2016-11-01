//
//  EIArcball.swift
//  HelloMetal
//
//  Created by Douglass Turner on 9/28/16.
//  Copyright © 2016 Elastic Image Software. All rights reserved.
//

import GLKit

class EIArcball {
 
    let kRotationRate = CGFloat(1.0/30.0);
    let kRotationDecelerationRate = CGFloat(1.0/60.0);

    var viewBounds: CGRect!
    
    var startVector: GLKVector3!

    var rotationTimer: Timer?
    
    var ballCenter = CGPoint(x:0.0, y:0.0)
    var ballRadius = CGFloat(1.0)
    
    var quaternion = GLKQuaternionIdentity
    var rotationMatrix = GLKMatrix4Identity
    
    var quaternionTouchDown = GLKQuaternionIdentity
    var rotationMatrixTouchDown = GLKMatrix4Identity
    
    var angleOfRotation = Float(0)
    var axisOfRotation = GLKVector3Make(0, 0, 0);
    
    init(viewBounds: CGRect) {
        self.viewBounds = viewBounds
    }

    func reshape (viewBounds: CGRect) {
        self.viewBounds = viewBounds
    }

    func beginDrag(screenLocation: CGPoint) {
        
        if (nil != rotationTimer) {
            rotationTimer!.invalidate()
            rotationTimer = nil;
        }
        
        startVector = ballLocationInXYPlane(screenLocation: screenLocation)
    }

    func updateDrag (screenLocation: CGPoint) {

        let endVector = ballLocationInXYPlane(screenLocation: screenLocation)

        angleOfRotation = acos(GLKVector3DotProduct(startVector, endVector))
        axisOfRotation = GLKVector3CrossProduct(startVector, endVector)

        quaternion = GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndVector3Axis(angleOfRotation, axisOfRotation), quaternionTouchDown)
        
        rotationMatrix = GLKMatrix4MakeWithQuaternion(quaternion)
    }
    
    func endDrag(velocityInView:CGPoint, locationInView:CGPoint) {
 
        quaternionTouchDown = quaternion
        rotationMatrixTouchDown = rotationMatrix
        
        let xx = CGFloat(kRotationRate * CGFloat(velocityInView.x)) + CGFloat(locationInView.x)
        let yy = CGFloat(kRotationRate * CGFloat(velocityInView.y)) + CGFloat(locationInView.y)
        let screenLocationTo = CGPoint(x:xx, y:yy)
        
        let a = ballLocationInXYPlane(screenLocation:locationInView)
        let b = ballLocationInXYPlane(screenLocation:screenLocationTo)
        
        let radians = acos(GLKVector3DotProduct(a, b));

//        rotationTimer = Timer.scheduledTimer(timeInterval: TimeInterval(kRotationRate),
//                                             target:self,
//                                             selector: Selector(("rotationTimerHandler")),
//                                             userInfo: [ "radiansBegin":radians, "radians":radians, "radiansEnd":0, "counter":0 ],
//                                             repeats: true)
    }
    
    func rotationTimerHandler(timer:Timer) {
        
        var anglePackage = timer.userInfo as! Dictionary<String, AnyObject>
        
        let radiansBegin = anglePackage["radiansBegin"] as! CGFloat
        var radians      = anglePackage["radians"] as! Float
        
        if (radians < 0) {
            
            timer.invalidate()
        } else {
            
            radians -= Float(kRotationDecelerationRate * radiansBegin)
            anglePackage["radians"] = radians as AnyObject?
            
            let quaternionDrag = GLKQuaternionMakeWithAngleAndVector3Axis(radians, axisOfRotation)
            quaternion = GLKQuaternionMultiply(quaternionDrag, quaternionTouchDown)
            rotationMatrix = GLKMatrix4MakeWithQuaternion(quaternion)
            
            quaternionTouchDown = quaternion
            rotationMatrixTouchDown = rotationMatrix
        }
    }

    func ballLocationInXYPlane(screenLocation:CGPoint) -> GLKVector3 {

        let locationInBallCoordinates = self.locationInBallCoordinates(screenLocation:screenLocation)

        var ballLocation_x: CGFloat
        ballLocation_x = (locationInBallCoordinates.x - ballCenter.x) / ballRadius;

        var ballLocation_y: CGFloat
        ballLocation_y = (locationInBallCoordinates.y - ballCenter.y) / ballRadius;

        let magnitude = ballLocation_x * ballLocation_x + ballLocation_y * ballLocation_y

        if (magnitude > 1.0) {
            let scale = 1.0/sqrt(magnitude)
            ballLocation_x *= scale;
            ballLocation_y *= scale;
            return GLKVector3(v:(Float(ballLocation_x), Float(ballLocation_y), Float(0)))
        } else {
            return GLKVector3(v:(Float(ballLocation_x), Float(ballLocation_y), Float(sqrt(1 - magnitude))))
        }

    }

    func ballLocationInXZPlane(screenLocation:CGPoint) -> GLKVector3 {

        let locationInBallCoordinates = self.locationInBallCoordinates(screenLocation:screenLocation)

        var ballLocation_x: CGFloat
        ballLocation_x = (locationInBallCoordinates.x - ballCenter.x) / ballRadius;

        var ballLocation_z: CGFloat
        ballLocation_z = (locationInBallCoordinates.y - ballCenter.y) / ballRadius;

        let magnitude = ballLocation_x * ballLocation_x + ballLocation_z * ballLocation_z

        if (magnitude > 1.0) {
            let scale = 1.0/sqrt(magnitude)
            ballLocation_x *= scale;
            ballLocation_z *= scale;
            return GLKVector3(v:(Float(ballLocation_x), Float(0), Float(ballLocation_z)))
        } else {
            return GLKVector3(v:(Float(ballLocation_x), Float(-sqrt(1 - magnitude)), Float(ballLocation_z)))
        }

    }

    func locationInBallCoordinates(screenLocation:CGPoint) -> CGPoint {
        
//        viewBounds.description(blurb:"view")

        let ballBBoxSizeScreenCoordinates = max(viewBounds.width, viewBounds.height)

        // -1 to +1
        var screenLocationInBallCoordinates_x: CGFloat
        screenLocationInBallCoordinates_x = (2.0 * (screenLocation.x - viewBounds.origin.x) / viewBounds.size.width) - 1.0
        screenLocationInBallCoordinates_x *= (viewBounds.size.width / ballBBoxSizeScreenCoordinates);

        var screenLocationInBallCoordinates_y: CGFloat
        screenLocationInBallCoordinates_y = (2.0 * (screenLocation.y - viewBounds.origin.y) / viewBounds.size.height) - 1.0
        screenLocationInBallCoordinates_y *= (viewBounds.size.height / ballBBoxSizeScreenCoordinates);

        // flip y
        screenLocationInBallCoordinates_y *= -1.0;

        return CGPoint(x:screenLocationInBallCoordinates_x, y:screenLocationInBallCoordinates_y);
    }

    @objc func arcBallPanHandler(panGester:UIPanGestureRecognizer) {
        
        switch (panGester.state) {
            
        case .began:
            beginDrag(screenLocation: panGester.location(in: panGester.view))
            
        case .changed:
            updateDrag(screenLocation: panGester.location(in: panGester.view))
            
        case .ended:
            endDrag(
                velocityInView: panGester.velocity(in: panGester.view),
                locationInView: panGester.location(in: panGester.view))
            
        default:
            fatalError("Error: Unrecognized pan gesture state.")
            
        }
        

    }

}
