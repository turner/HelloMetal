//
//  MTKTextureLoader+EIMakeWithUIImage.swift
//  HelloMetal
//
//  Created by Douglass Turner on 12/19/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import MetalKit
extension MTKTextureLoader {

    static func EIMakeWithUIImage(device: MTLDevice, name:String) -> MTLTexture {
        
        guard let image = UIImage(named:name) else {
            fatalError("Error: Can not load UIImage named \(name)")
        }

        let texture:MTLTexture

        do {
            let textureLoader = MTKTextureLoader(device: device)
            let textureLoaderOptions:[MTKTextureLoader.Option : Any] =
                    [
                        .generateMipmaps: true,
                        .SRGB: false
                    ]

            texture = try textureLoader.newTexture(cgImage: image.cgImage!, options: textureLoaderOptions)
        } catch {
            fatalError("Error: Can not create texture from UIImage named \(name)")
        }

        return texture
    }
}
