//
//  EIScene+Configuration_CameraPlane.swift
//  HelloCameraPlane
//
//  Created by Douglass Turner on 1/2/19.
//  Copyright © 2019 Elastic Image Software. All rights reserved.
//

import GLKit
import MetalKit
extension EIScene {
    
    func configure(view: EIView, renderer:EIRendererEngine) {
        
        self.renderer = renderer
        view.delegate = renderer
    
        renderer.camera = EICamera(location:GLKVector3Make(0, 0, 1000), target:GLKVector3Make(0, 0, 0), approximateUp:GLKVector3Make(0, 1, 0))

        var shader:EIShader
        
        // hero - mesh
        let hm = EIMesh.plane(device: view.device!, xExtent: 256, zExtent: 256, xTesselation: 32, zTesselation: 32)
        
        // hero - shader
        shader = EIShader(device:view.device!, vertex:"texture_vertex", fragment:"texture_fragment", textureNames:["kids_grid_3x3_translucent"])
        
        // hero - model
        let hero = EIModel(view:view, model:hm, shader:shader, transformer:{
            return view.arcBall.rotationMatrix * GLKMatrix4MakeRotation(GLKMathDegreesToRadians(90), 1, 0, 0)
        })
        
        // cameraPlane - mesh
        let cpm = EIMesh.plane(device: view.device!, xExtent: 2, zExtent: 2, xTesselation: 4, zTesselation: 4)

        // cameraPlane - shader
        shader = EIShader(device:view.device!, vertex:"texture_vertex", fragment:"texture_fragment", textureNames:["mobile"])

        // cameraPlane - model
        let cameraPlane = EIModel(view:view, model:cpm, shader:shader, transformer:{ [unowned self] in
            return self.renderer.camera.createRenderPlaneTransform(distanceFromCamera: 0.75 * self.renderer.camera.far) * GLKMatrix4MakeRotation(GLKMathDegreesToRadians(90), 1, 0, 0)
        })
        
        // NOTE: When using translucent textures render opacque objects first (cameraPlane)
        //       then translucent object (hero with kids_grid_3x3_translucent)
        renderer.models.append(cameraPlane)
        renderer.models.append(hero)

    }
}
