//
//  EIScene+Configuration_RenderPass.swift
//  HelloRenderPass
//
//  Created by Douglass Turner on 1/3/19.
//  Copyright © 2019 Elastic Image Software. All rights reserved.
//

import GLKit
import MetalKit
extension EIScene {
    
    func configure(view: EIView, renderer:EIRendererEngine) {
        
        self.renderer = renderer
        view.delegate = renderer
        
        var shader:EIShader
        
        renderer.camera = EICamera(location:GLKVector3Make(0, 0, 1000), target:GLKVector3Make(0, 0, 0), approximateUp:GLKVector3Make(0, 1, 0))

        // hero
        shader = EIShader(device:view.device!, vertex:"hello_texture_vertex", fragment:"hello_texture_fragment", textureNames:["kids_grid_3x3_translucent"])
        
        let hero = EIModel(view:view, model:EIQuad(device: view.device!), shader:shader, transformer:{
            return view.arcBall.rotationMatrix * GLKMatrix4MakeScale(150, 150, 1)
        })
        
        // camera plane
        shader = EIShader(device:view.device!, vertex:"hello_texture_vertex", fragment:"hello_texture_fragment", textureNames:["mobile"])
        
        let cameraPlane = EIModel(view:view, model:EIQuad(device: view.device!), shader:shader, transformer:{ [unowned self] in
            return self.renderer.camera.createRenderPlaneTransform(distanceFromCamera: 0.35 * self.renderer.camera.far)
        })
        
        renderer.models.append(cameraPlane)
        renderer.models.append(hero)

    }
}
