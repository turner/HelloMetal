//
//  EIScene+Configuration_Light.swift
//  HelloLight
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
        
        renderer.camera = EICamera(location:GLKVector3(v:(0, 0, 1000)), target:GLKVector3(v:(0, 0, 0)), approximateUp:GLKVector3(v:(0, 1, 0)))
        
        var shader:EIShader
        
        // hero
        
        // Lee Perry Smith head model
        let   heroMesh = EIMesh.sceneMesh(device:view.device!, sceneName:"scenes.scnassets/lee_perry_smith.scn", nodeName:"LeePerrySmith")

        // teapot
        //        let heroMesh = EIMesh.sceneMesh(device:view.device!, sceneName:"scenes.scnassets/teapot.scn", nodeName:"teapotIdentity")
        
        shader = EIShader(device:view.device!, vertex:"model_io_texture_lit_vertex", fragment:"model_io_texture_lit_fragment", textureNames:["lee_perry_smith_albedo"])
        
        let hero = EIModel(view:view, model:heroMesh, shader:shader, transformer:{
            
            // scale for Lee Perry Smith head model
            return view.arcBall.rotationMatrix * GLKMatrix4MakeScale(50, 50, 50) * GLKMatrix4MakeTranslation(0, 0, 0)

            // scale for teapot
            //            return view.arcBall.rotationMatrix * GLKMatrix4MakeScale(250, 250, 250)
        })
        
        
        // camera plane
        
        let cameraPlaneMesh = EIMesh.plane(device: view.device!, xExtent: 2, zExtent: 2, xTesselation: 4, zTesselation: 4)
        shader = EIShader(device:view.device!, vertex:"model_io_texture_vertex", fragment:"model_io_texture_fragment", textureNames:["mobile"])
        
        let cameraPlane = EIModel(view:view, model:cameraPlaneMesh, shader:shader, transformer:{ [unowned self] in
            return self.renderer.camera.createRenderPlaneTransform(distanceFromCamera: 0.75 * self.renderer.camera.far) * GLKMatrix4MakeRotation(GLKMathDegreesToRadians(90), 1, 0, 0)
        })
        
        renderer.models.append(hero)
        renderer.models.append(cameraPlane)

    }
}
