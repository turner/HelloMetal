//
//  EIRenderPassEngine.swift
//  HelloRenderPass
//
//  Created by Douglass Turner on 12/13/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import MetalKit
import GLKit
class EIRenderPassEngine : EIRendererEngine {
    
    var finalPassModel:EIModel!
    
    override init(view: EIView, device: MTLDevice) {

        super.init(view: view, device: device)
        
        let shader =
            EIShader(view:view, library:view.defaultLibrary, vertex:"finalPassVertexShader", fragment:"finalPassOverlayFragmentShader", textureNames:["mobile-overlay"], vertexDescriptor: nil)
        
        finalPassModel =
            EIModel(model:EIQuad(device: view.device!), shader:shader, transformer:{
            return self.camera.createRenderPlaneTransform(distanceFromCamera: 0.75 * self.camera.far)
        })
        
        models.append(finalPassModel)

    }
    
}
