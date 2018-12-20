//
//  MTKTextureLoader+OpenEXR.swift
//  HelloOpenEXR
//
//  Created by Douglass Turner on 12/20/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import MetalKit
extension MTKTextureLoader {
    
    static func newTexture_OpenEXR(device: MTLDevice, name:String) -> MTLTexture {

        guard let url = Bundle.main.url(forResource:name, withExtension:nil) else {
            fatalError("Error: Can not find OpenEXR texture named \(name)")
        }

        let wp = UnsafeMutablePointer<CLong>.allocate(capacity: 1)
        let hp = UnsafeMutablePointer<CLong>.allocate(capacity: 1)
        let theBits:UnsafePointer<CUnsignedShort> = pokeOpenEXR(url.path, wp, hp)

        // NOTE: Setting mipmapped to true DOES enable mipmap but the texture goes transparent when viewed close to edge on.
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba16Float, width: wp.pointee, height: hp.pointee, mipmapped: false)

        guard let t = device.makeTexture(descriptor: textureDescriptor) else {
            fatalError("Error: Can not create OpenEXR texture with file named \(name)")
        }

        let region = MTLRegionMake2D(0, 0, wp.pointee, hp.pointee)
        let bytesPerRow = wp.pointee * MemoryLayout<CUnsignedShort>.size * 4
        t.replace(region: region, mipmapLevel: 0, withBytes: theBits, bytesPerRow: bytesPerRow)

        return t
    }
}
