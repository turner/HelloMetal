//
//  EIOpenEXRTexture.swift
//  HelloOpenEXR
//
//  Created by Douglass Turner on 12/12/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import MetalKit
struct EIOpenEXRTexture {
    
    let texture:MTLTexture
    
    init(device: MTLDevice, name:String) {
        
        let url = Bundle.main.url(forResource:name, withExtension:nil)
        let path = url?.path
        
        let wp = UnsafeMutablePointer<CLong>.allocate(capacity: 1)
        let hp = UnsafeMutablePointer<CLong>.allocate(capacity: 1)
        let theBits:UnsafePointer<CUnsignedShort>
        theBits = pokeOpenEXR(path, wp, hp)
        
        //    let length = 4 * width * height
        //    let buffer = UnsafeBufferPointer(start: theBits, count: length);
        
        let byteCount = wp.pointee * hp.pointee * MemoryLayout<CUnsignedShort>.size * 4
        let mtlBuffer:MTLBuffer = device.makeBuffer(bytes:theBits, length:byteCount, options:.storageModeShared)!
        
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat:.rgba16Float, width:wp.pointee, height:hp.pointee, mipmapped:false)
        
        let bytesPerPixel = MemoryLayout<CUnsignedShort>.size * 4
        let bytesPerRow = bytesPerPixel * wp.pointee
        
        texture = mtlBuffer.makeTexture(descriptor:descriptor, offset: 0, bytesPerRow:bytesPerRow)!
    
    }

}
