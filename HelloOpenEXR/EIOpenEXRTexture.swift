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
        
        guard let url = Bundle.main.url(forResource:name, withExtension:nil) else {
            fatalError("Error: Can not find OpenEXR texture named \(name)")
        }

        let wp = UnsafeMutablePointer<CLong>.allocate(capacity: 1)
        let hp = UnsafeMutablePointer<CLong>.allocate(capacity: 1)
        let theBits:UnsafePointer<CUnsignedShort> = pokeOpenEXR(url.path, wp, hp)

        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba16Float, width: wp.pointee, height: hp.pointee, mipmapped: false)

        guard let t = device.makeTexture(descriptor: textureDescriptor) else {
            fatalError("Error: Can not create OpenEXR texture with file named \(name)")
        }

        texture = t

        let region = MTLRegionMake2D(0, 0, wp.pointee, hp.pointee)

        let bytesPerRow = wp.pointee * MemoryLayout<CUnsignedShort>.size * 4

        texture.replace(region: region, mipmapLevel: 0, withBytes: theBits, bytesPerRow: bytesPerRow)
    
    }

}
