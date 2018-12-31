//
//  EIScene_Hello.swift
//  Hello
//
//  Created by Douglass Turner on 12/31/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import GLKit
import MetalKit
class EIScene_Hello : EIScene {
    
    override init(view: EIView, renderer:EIRendererEngine) {
        
        renderer.camera = EICamera(location:GLKVector3(v:(0, 0, 1000)), target:GLKVector3(v:(0, 0, 0)), approximateUp:GLKVector3(v:(0, 1, 0)))
        
        let shader = EIShader(device:view.device!, vertex:"hello_texture_vertex", fragment:"hello_texture_fragment", textureNames:["kids_grid_3x3"])
        
        let model = EIModel(view:view, model:EIQuad(device: view.device!), shader:shader, transformer:{
            return view.arcBall.rotationMatrix * GLKMatrix4MakeScale(150, 150, 1)
        })
        
        renderer.models.append(model)
        
        super.init(view: view, renderer:renderer)

    }
}
