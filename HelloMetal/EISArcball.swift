//
//  EISArcball.swift
//  HelloMetal
//
//  Created by Douglass Turner on 9/28/16.
//  Copyright © 2016 Elastic Image Software. All rights reserved.
//

import GLKit

class EISArcball {
 
    let kRotationRate = CGFloat(1.0/30.0);
    let kRotationDecelerationRate = CGFloat(1.0/60.0);

    var viewBounds: CGRect!
    
    var fromVector: GLKVector3!
    var toVector: GLKVector3!
    
    var rotationTimer: Timer?
    
    var ballCenter = CGPoint(x:0.0, y:0.0)
    var ballRadius = Float(1.0)
    
    var quaternion = GLKQuaternionIdentity
    var rotationMatrix = GLKMatrix4Identity
    
    var quaternionTouchDown = GLKQuaternionIdentity
    var rotationMatrixTouchDown = GLKMatrix4Identity
    
    var rotationAngle = Float(0)
    var rotationAxis = GLKVector3Make(0, 0, 0);
    
    init(viewBounds: CGRect) {
        self.viewBounds = viewBounds
    }
    
    func beginDrag(screenLocation: CGPoint) {
        
        if (nil != rotationTimer) {
            rotationTimer!.invalidate()
            rotationTimer = nil;
        }
        
        fromVector = ballLocation(screenLocation: screenLocation)
        
    }

    func updateDrag (screenLocation: CGPoint) {
        toVector = ballLocation(screenLocation: screenLocation)
        rotationAngle = acos(GLKVector3DotProduct(fromVector, toVector))
        rotationAxis = GLKVector3CrossProduct(fromVector, toVector)
        
        let quaternionDrag = GLKQuaternionMakeWithAngleAndVector3Axis(rotationAngle, rotationAxis)
        quaternion = GLKQuaternionMultiply(quaternionDrag, quaternionTouchDown)
        
        rotationMatrix = GLKMatrix4MakeWithQuaternion(quaternion)
    }
    
    func endDrag(velocityInView:CGPoint, locationInView:CGPoint) {
 
        quaternionTouchDown = quaternion
        rotationMatrixTouchDown = rotationMatrix
        
        let xx = CGFloat(kRotationRate * CGFloat(velocityInView.x)) + CGFloat(locationInView.x)
        let yy = CGFloat(kRotationRate * CGFloat(velocityInView.y)) + CGFloat(locationInView.y)
        let screenLocationTo = CGPoint(x:xx, y:yy)
        
        let a = ballLocation(screenLocation:locationInView)
        let b = ballLocation(screenLocation:screenLocationTo)
        
        let radians = acos(GLKVector3DotProduct(a, b));
        
        rotationTimer =
            Timer.scheduledTimer(
                timeInterval: TimeInterval(kRotationRate),
                target: self,
                selector: #selector(EISArcball.rotationTimerHandler),
                userInfo: [ "radiansBegin":radians, "radians":radians, "radiansEnd":0, "counter":0 ],
                repeats: true)
        
    }
    
    @objc func rotationTimerHandler(timer:Timer) {
        
        var anglePackage = timer.userInfo as! Dictionary<String, AnyObject>
        
        let radiansBegin = anglePackage["radiansBegin"] as! CGFloat
        var radians      = anglePackage["radians"] as! Float
        
        if (radians < 0) {
            
            timer.invalidate()
        } else {
            
            radians -= Float(kRotationDecelerationRate * radiansBegin)
            anglePackage["radians"] = radians as AnyObject?
            
            let quaternionDrag = GLKQuaternionMakeWithAngleAndVector3Axis(radians, rotationAxis)
            quaternion = GLKQuaternionMultiply(quaternionDrag, quaternionTouchDown)
            rotationMatrix = GLKMatrix4MakeWithQuaternion(quaternion)
            
            quaternionTouchDown = quaternion
            rotationMatrixTouchDown = rotationMatrix
        }
    }
    
    func ballLocation(screenLocation:CGPoint) -> GLKVector3 {
        
        let locationInBallCoordinates = self.locationInBallCoordinates(screenLocation:screenLocation)
        var ballLocation = GLKVector3(v:(Float(locationInBallCoordinates.x - ballCenter.x)/ballRadius, 0, Float(locationInBallCoordinates.y - ballCenter.y)/ballRadius))
        
        let magnitude = ballLocation.x * ballLocation.x + ballLocation.z * ballLocation.z
        
        if (magnitude > 1.0) {
            ballLocation = GLKVector3MultiplyScalar(ballLocation, 1.0/sqrt(magnitude))
        } else {
            ballLocation = GLKVector3(v:(ballLocation.x, -sqrt(1 - magnitude), ballLocation.z))
        }
        
        return ballLocation
        
    }
    
    func locationInBallCoordinates(screenLocation:CGPoint) -> CGPoint {
        
        // -1 to +1
        var screenLocationInBallCoordinates: CGPoint
        
        // ball radius is half the size of the maximum dimension of screen bounds
        // NOTE: This is less pleasing. Weirdness happens when we go outside the bounds of the sphere.
        //    CGFloat ballBBoxSizeScreenCoordinates = MIN(CGRectGetWidth(_viewBounds), CGRectGetHeight(_viewBounds));
        
        // ball radius is half the size of the maximum dimension of screen bounds.
        // NOTE: This gives more pleasing U/X
        let ballBBoxSizeScreenCoordinates = max(viewBounds.width, viewBounds.height)
        
        let numerX = screenLocation.x - viewBounds.origin.x
        let denomX = viewBounds.size.width
        let numerY = screenLocation.y - viewBounds.origin.y
        let denomY = viewBounds.size.height
        
        screenLocationInBallCoordinates = CGPoint(x:(2.0 * numerX/denomX) - 1.0, y:(2.0 * numerY/denomY) - 1.0);
        
        screenLocationInBallCoordinates = CGPoint(x:screenLocationInBallCoordinates.x * (viewBounds.width/ballBBoxSizeScreenCoordinates), y:screenLocationInBallCoordinates.y * (viewBounds.height/ballBBoxSizeScreenCoordinates));

        // flip y
        screenLocationInBallCoordinates = CGPoint(x:screenLocationInBallCoordinates.x, y:-screenLocationInBallCoordinates.y);
        
        return screenLocationInBallCoordinates;
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
