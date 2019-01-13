//
//  MTLDevice+EIMakeSampler.swift
//  HelloMetal
//
//  Created by Douglass Turner on 1/13/19.
//  Copyright © 2019 Elastic Image Software. All rights reserved.
//

import Metal
extension MTLDevice {
    
    public func EIMakeSamplerState() -> MTLSamplerState? {
        
        let samplerDescriptor = MTLSamplerDescriptor()
        
        // texture coordinate 0..1
        samplerDescriptor.normalizedCoordinates = true
        
        // bi-linear mipmap filtering
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.mipFilter = .linear
        
        guard let samplerState = makeSamplerState(descriptor: samplerDescriptor) else {
            fatalError("Error: Can not create sampler state ")
        }

        return samplerState
    }
}
