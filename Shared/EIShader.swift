//
//  EIShader.swift
//  HelloMetal
//
//  Created by Douglass Turner on 12/7/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import MetalKit
struct EIShader {
    
    let vertex:String
    let fragment:String
    
    var textures: [MTLTexture] = [MTLTexture]()

    init(vertex:String, fragment:String, textures:[MTLTexture]) {
        
        self.vertex = vertex
        self.fragment = fragment
        for i in 0..<textures.count {
            self.textures.append(textures[ i ])
        }
        
    }

    init(device:MTLDevice, vertex:String, fragment:String, textureNames:[String]) {
        
        self.vertex = vertex
        self.fragment = fragment
        for i in 0..<textureNames.count {
            textures.append(MTKTextureLoader.newTexture_UIImage(device: device, name: textureNames[i]))
        }

    }
}
