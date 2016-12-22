//
//  openexr.swift
//  HelloMetal
//
//  Created by Douglass Turner on 12/22/16.
//  Copyright © 2016 Elastic Image Software. All rights reserved.
//

import MetalKit

func tickleOpenEXR(device: MTLDevice, name:String)  {
    
    let wp = UnsafeMutablePointer<CLong>.allocate(capacity: 1)
    let hp = UnsafeMutablePointer<CLong>.allocate(capacity: 1)
    let theBits:UnsafePointer<CUnsignedShort>
    
    let url = Bundle.main.url(forResource:name, withExtension:nil)
    let path = url?.path
    
    theBits = pokeOpenEXR(path, wp, hp)
    
    let width = wp.pointee
    let height = hp.pointee
    
    let length = 4 * width * height
    let buffer = UnsafeBufferPointer(start: theBits, count: length);
    
    print("main unsigned short \(MemoryLayout<CUnsignedShort>.size)")
    
    for index in 0 ..< 4 * width {
        print("main \(index % 4) \(buffer[ index ])")
    }
    
    print("main file \(name) width \(width) height \(height) length of bit buffer  \(buffer.count)\n")
    
}
