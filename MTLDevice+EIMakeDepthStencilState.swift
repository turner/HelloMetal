//
//  MTLDevice.EIMakeDepthStencilState.swift
//  HelloMetal
//
//  Created by Douglass Turner on 1/13/19.
//  Copyright © 2019 Elastic Image Software. All rights reserved.
//

import MetalKit
extension MTLDevice {
    
    public func EIMakeDepthStencilState() -> MTLDepthStencilState? {
        
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = true
        
        guard let dss = makeDepthStencilState(descriptor: depthStencilDescriptor) else {
            fatalError("Error: Can not create depth stencil state")
        }
        
        return dss

    }
}
