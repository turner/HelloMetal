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
        
        // hero - EIQuad
        //        let hq = EIQuad(device: view.device!)
        //        shader = EIShader(device:view.device!, vertex:"hello_texture_vertex", fragment:"hello_texture_fragment", textureNames:["kids_grid_3x3_translucent"], vertexDescriptor: nil)
        //        let hero = EIModel(view:view, model:hq, shader:shader, transformer:{
        //            return view.arcBall.rotationMatrix * GLKMatrix4MakeScale(150, 150, 1)
        //        })
        
        // hero - EIMesh
        let hm = EIMesh.plane(device: view.device!, xExtent: 256, zExtent: 256, xTesselation: 32, zTesselation: 32)
        shader = EIShader(device:view.device!, vertex:"model_io_texture_vertex", fragment:"model_io_texture_fragment", textureNames:["kids_grid_3x3_translucent"])
        let hero = EIModel(view:view, model:hm, shader:shader, transformer:{
            return view.arcBall.rotationMatrix * GLKMatrix4MakeRotation(GLKMathDegreesToRadians(90), 1, 0, 0)
        })
        
        // cameraPlane
        
        //        let cpq = EIQuad(device: view.device!)
        //        shader = EIShader(view:view, library:view.defaultLibrary, vertex:"hello_texture_vertex", fragment:"hello_texture_fragment", textureNames:["mobile"], vertexDescriptor:nil)
        
        let plane = EIMesh.plane(device: view.device!, xExtent: 2, zExtent: 2, xTesselation: 4, zTesselation: 4)
        shader = EIShader(device:view.device!, vertex:"model_io_texture_vertex", fragment:"model_io_texture_fragment", textureNames:["mobile"])
        
        let cameraPlane = EIModel(view:view, model:plane, shader:shader, transformer:{ [unowned self] in
            
            // EIQuad
            //            return self.renderer.camera.createRenderPlaneTransform(distanceFromCamera: 0.75 * self.renderer.camera.far)
            
            // EIMesh.plane
            return self.renderer.camera.createRenderPlaneTransform(distanceFromCamera: 0.75 * self.renderer.camera.far) * GLKMatrix4MakeRotation(GLKMathDegreesToRadians(90), 1, 0, 0)
        })
        
        // NOTE: When here uses translucent texture. rendering IS ORDER DEPENDENT.
        //       Render opacque objects first - cameraPlane
        //       then translucent object - hero with kids_grid_3x3_translucent
        renderer.models.append(cameraPlane)
        renderer.models.append(hero)

    }
}
