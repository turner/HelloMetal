//
//  EITexture.swift
//  HelloMetal
//
//  Created by Douglass Turner on 10/26/16.
//  Copyright © 2016 Elastic Image Software. All rights reserved.
//

import MetalKit

enum EITextureError: Error {
    case UIImageCreationError
    case MTKTextureLoaderError
}

func makeTexture(device: MTLDevice, name:String) throws -> MTLTexture {
    
    guard let image = UIImage(named:name) else {
        throw EITextureError.UIImageCreationError
    }
    
    do {
        let textureLoader = MTKTextureLoader(device: device)
        let textureLoaderOptions:[String:NSNumber] = [ MTKTextureLoaderOptionSRGB:false ]
        
        return try textureLoader.newTexture(with: image.cgImage!, options: textureLoaderOptions)
    }
    
}
