//
//  MTLDevice+MakeCommandQueue.swift
//  HelloMetal
//
//  Created by Douglass Turner on 1/13/19.
//  Copyright © 2019 Elastic Image Software. All rights reserved.
//

import MetalKit
extension MTLDevice {
    
    public func EIMakeCommandQueue() -> MTLCommandQueue? {

        guard let commandQueue = makeCommandQueue() else {
            fatalError("Error: Can not create command queue")
        }
        
        return commandQueue
    }
}
