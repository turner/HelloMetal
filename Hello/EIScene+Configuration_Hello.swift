//
//  EIScene+Configuration_Hello.swift
//  Hello
//
//  Created by Douglass Turner on 1/1/19.
//  Copyright © 2019 Elastic Image Software. All rights reserved.
//
import GLKit
import MetalKit
extension EIScene {
    
    func configure(view: EIView, renderer:EIRendererEngine) {
        
        self.renderer = renderer
        view.delegate = renderer

        renderer.camera = EICamera(location:GLKVector3Make(0, 0, 1000), target:GLKVector3Make(0, 0, 0), approximateUp:GLKVector3Make(0, 1, 0))
        
        let shader = EIShader(device:view.device!, vertex:"hello_texture_vertex", fragment:"hello_texture_fragment", textureNames:["kids_grid_3x3"])
        
        let model = EIModel(view:view, model:EIQuad(device: view.device!), shader:shader, transformer:{
            return view.arcBall.rotationMatrix * GLKMatrix4MakeScale(150, 150, 1)
        })
        
        renderer.models.append(model)
        
    }
}
