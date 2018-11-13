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
        let textureLoaderOptions:[String:NSNumber] = [ convertFromMTKTextureLoaderOption(MTKTextureLoader.Option.SRGB):false ]
        
        return try textureLoader.newTexture(cgImage: image.cgImage!, options: convertToOptionalMTKTextureLoaderOptionDictionary(textureLoaderOptions))
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromMTKTextureLoaderOption(_ input: MTKTextureLoader.Option) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalMTKTextureLoaderOptionDictionary(_ input: [String: Any]?) -> [MTKTextureLoader.Option: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (MTKTextureLoader.Option(rawValue: key), value)})
}
