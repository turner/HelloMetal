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

    // EIMesh - SceneKit - lee_perry_smith.scn
    func /*lee_perry_smith_*/configure(view: EIView, renderer:EIRendererEngine) {
        
        self.renderer = renderer
        view.delegate = renderer
        
        renderer.camera = EICamera(location:GLKVector3(v:(0, 0, 1000)), target:GLKVector3(v:(0, 0, 0)), approximateUp:GLKVector3(v:(0, 1, 0)))
        
        var shader:EIShader
        
        // hero
        
        // Lee Perry Smith head model
        let   heroMesh = EIMesh.sceneMesh(device:view.device!, sceneName:"scenes.scnassets/lee_perry_smith.scn", nodeName:"LeePerrySmith")
        
        // teapot
        //        let heroMesh = EIMesh.sceneMesh(device:view.device!, sceneName:"scenes.scnassets/teapot.scn", nodeName:"teapotIdentity")
        
        shader = EIShader(device:view.device!, vertex:"texture_lit_vertex", fragment:"texture_lit_fragment", textureNames:["lee_perry_smith_albedo"])
        
        let hero = EIModel(view:view, model:heroMesh, shader:shader, transformer:{
            
            // scale for Lee Perry Smith head model
            return view.arcBall.rotationMatrix * GLKMatrix4MakeScale(50, 50, 50) * GLKMatrix4MakeTranslation(0, 0, 0)
            
            // scale for teapot
            //            return view.arcBall.rotationMatrix * GLKMatrix4MakeScale(250, 250, 250)
        })
        
        
        // camera plane
        
        let cameraPlaneMesh = EIMesh.plane(device: view.device!, xExtent: 2, zExtent: 2, xTesselation: 4, zTesselation: 4)
        shader = EIShader(device:view.device!, vertex:"texture_vertex", fragment:"texture_fragment", textureNames:["mobile"])
        
        let cameraPlane = EIModel(view:view, model:cameraPlaneMesh, shader:shader, transformer:{ [unowned self] in
            return self.renderer.camera.createRenderPlaneTransform(distanceFromCamera: 0.75 * self.renderer.camera.far) * GLKMatrix4MakeRotation(GLKMathDegreesToRadians(90), 1, 0, 0)
        })
        
        renderer.models.append(cameraPlane)
        renderer.models.append(hero)

    }
    
    // EIMesh - Cube
    func cube_configure(view: EIView, renderer:EIRendererEngine) {
        
        self.renderer = renderer
        view.delegate = renderer
        
        renderer.camera = EICamera(location:GLKVector3(v:(0, 0, 1000)), target:GLKVector3(v:(0, 0, 0)), approximateUp:GLKVector3(v:(0, 1, 0)))
        
        var shader:EIShader
        
        // hero
        let cube = EIMesh.cube(device: view.device!, xExtent: 200, yExtent: 100, zExtent: 200, xTesselation: 32, yTesselation: 32, zTesselation: 32)
        shader = EIShader(device:view.device!, vertex:"texture_vertex", fragment:"texture_fragment", textureNames:["mandrill"])
        
        let hero = EIModel(view:view, model:cube, shader:shader, transformer:{
            return view.arcBall.rotationMatrix
        })
        
        // camera plane
        let plane = EIMesh.plane(device: view.device!, xExtent: 2, zExtent: 2, xTesselation: 4, zTesselation: 4)
        shader = EIShader(device: view.device!, vertex:"texture_vertex", fragment:"texture_fragment", textureNames:["mobile"])
        
        let cameraPlane = EIModel(view:view, model:plane, shader:shader, transformer:{ [unowned self] in
            return self.renderer.camera.createRenderPlaneTransform(distanceFromCamera: 0.75 * self.renderer.camera.far) * GLKMatrix4MakeRotation(GLKMathDegreesToRadians(90), 1, 0, 0)
        })
        
        renderer.models.append(cameraPlane)
        renderer.models.append(hero)
    }
    
    // EIMesh - Plane
    func plane_configure(view: EIView, renderer:EIRendererEngine) {
        
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
            // EIMesh.plane
            return self.renderer.camera.createRenderPlaneTransform(distanceFromCamera: 0.75 * self.renderer.camera.far) * GLKMatrix4MakeRotation(GLKMathDegreesToRadians(90), 1, 0, 0)
        })
        
        // NOTE: When using translucent textures render opacque objects first (cameraPlane)
        //       then translucent object (hero with kids_grid_3x3_translucent)
        renderer.models.append(cameraPlane)
        renderer.models.append(hero)
        
    }
    
}
