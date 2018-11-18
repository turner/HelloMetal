//
//  openexr.swift
//  HelloMetal
//
//  Created by Douglass Turner on 12/22/16.
//  Copyright © 2016 Elastic Image Software. All rights reserved.
//

import MetalKit

func textureFromOpenEXR(device: MTLDevice, name:String) -> MTLTexture {
    
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
    
    let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat:.rgba16Float,
                                                              width:wp.pointee,
                                                              height:hp.pointee,
                                                              mipmapped:false)
    
    let bytesPerPixel = MemoryLayout<CUnsignedShort>.size * 4
    let bytesPerRow = bytesPerPixel * wp.pointee
    return mtlBuffer.makeTexture(descriptor:descriptor, offset: 0, bytesPerRow:bytesPerRow)!
    
}
