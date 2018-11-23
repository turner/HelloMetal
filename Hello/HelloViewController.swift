//
//  HelloViewController.swift
//  Hello
//
//  Created by Douglass Turner on 11/22/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import UIKit
import GLKit

class HelloViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eiViewDidLoad(view as! EIView)
    }
    
    func eiViewDidLoad(_ view:EIView) {
        
        view.renderer = Renderer(view: view, device: view.device!)
        view.delegate = view.renderer

        view.renderer.camera = EICamera(location:GLKVector3(v:(0, 0, 1000)), target:GLKVector3(v:(0, 0, 0)), approximateUp:GLKVector3(v:(0, 1, 0)))
        
        view.renderer.model = EIQuad(device: view.device!);

        do {
            view.renderer.texture = try makeTexture(device: view.device!, name: "kids_grid_3x3")
        } catch {
            fatalError("Error: Can not load texture")
        }

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
