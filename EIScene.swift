//
//  EIScene.swift
//  HelloMetal
//
//  Created by Douglass Turner on 12/29/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import MetalKit
class EIScene {
    
    var renderer:EIRendererEngine!
    
    init(view:EIView, renderer:EIRendererEngine) {
        self.renderer = renderer
        view.delegate = renderer
    }
}
