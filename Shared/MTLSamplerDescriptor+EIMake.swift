//
//  MTLSamplerDescriptor+EIMake.swift
//  HelloMetal
//
//  Created by Douglass Turner on 12/13/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import MetalKit

extension MTLSamplerDescriptor {
    
    class func EIMake(device:MTLDevice) -> MTLSamplerState? {
        
        let samplerDescriptor = MTLSamplerDescriptor()
        
        // texture coordinate 0..1
        samplerDescriptor.normalizedCoordinates = true
        
        // bi-linear mipmap filtering
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.mipFilter = .linear
        
        return device.makeSamplerState(descriptor: samplerDescriptor)
        
    }
}
