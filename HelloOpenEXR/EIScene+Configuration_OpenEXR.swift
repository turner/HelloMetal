//
//  EIScene+Configuration_OpenEXR.swift
//  HelloOpenEXR
//
//  Created by Douglass Turner on 1/5/19.
//  Copyright © 2019 Elastic Image Software. All rights reserved.
//

import GLKit
import MetalKit
extension EIScene {
    
    func configure(view: EIView, renderer:EIRendererEngine) {
        
        self.renderer = renderer
        view.delegate = renderer
        
        renderer.camera = EICamera(location:GLKVector3(v:(0, 0, 500)), target:GLKVector3(v:(0, 0, 0)), approximateUp:GLKVector3(v:(0, 1, 0)))
        
        var shader:EIShader
        
        // hero
        let heroMesh = EIMesh.plane(device: view.device!, xExtent: 200, zExtent: 200, xTesselation: 2, zTesselation: 2)
        
        let textureName = "candycane-translucent.exr"
        //        let textureName = "mandrill.exr"
        //        let textureName = "alias_wavefront_diagnostic.exr"
        //        let textureName = "kids_grid_3x3_translucent.exr"
        
        let openEXRTexture = MTKTextureLoader.newTexture_OpenEXR(device: view.device!, name: textureName)
        
        shader = EIShader(vertex:"model_io_texture_vertex", fragment:"model_io_texture_openEXR_fragment", textures:[openEXRTexture])
        
        let hero = EIModel(view:view, model:heroMesh, shader:shader, transformer:{
            return view.arcBall.rotationMatrix * GLKMatrix4MakeRotation(GLKMathDegreesToRadians(90), 1, 0, 0)
        })
        
        
        // camera plane
        let cameraPlaneMesh = EIMesh.plane(device: view.device!, xExtent: 2, zExtent: 2, xTesselation: 4, zTesselation: 4)
        shader = EIShader(device:view.device!, vertex:"model_io_texture_vertex", fragment:"model_io_texture_fragment", textureNames:["mobile"])
        
        let cameraPlane = EIModel(view:view, model:cameraPlaneMesh, shader:shader, transformer:{ [unowned self] in
            return self.renderer.camera.createRenderPlaneTransform(distanceFromCamera: 0.75 * self.renderer.camera.far) * GLKMatrix4MakeRotation(GLKMathDegreesToRadians(90), 1, 0, 0)
        })
        
        renderer.models.append(cameraPlane)
        renderer.models.append(hero)

    }
}
