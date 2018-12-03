//
//  RenderPassViewController.swift
//  HelloRenderPass
//
//  Created by Douglass Turner on 11/24/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import UIKit
import GLKit

class RenderPassViewController: UIViewController {

    var renderer:RenderPassRenderer!

    override func viewDidLoad() {
        super.viewDidLoad()

        eiViewDidLoad(view as! EIView)
    }

    func eiViewDidLoad(_ view:EIView) {

        renderer = RenderPassRenderer(view: view, device: view.device!)
        view.delegate = renderer

        renderer.camera = EICamera(location:GLKVector3(v:(0, 0, 1000)), target:GLKVector3(v:(0, 0, 0)), approximateUp:GLKVector3(v:(0, 1, 0)))

        // model
        renderer.model = EIQuad(device: view.device!)

        do {
            renderer.texture = try makeTexture(device: view.device!, name: "kids_grid_3x3_translucent")
        } catch {
            fatalError("Error: Can not load model texture")
        }

        // backdrop
        renderer.backdropModel = EIQuad(device: view.device!)

        do {
            renderer.backdropTexture = try makeTexture(device: view.device!, name: "mobile")
        } catch {
            fatalError("Error: Can not load backdrop texture")
        }


        // final pass render surface
        renderer.finalPassModel = EIQuad(device: view.device!)

        do {
            renderer.finalPassTexture = try makeTexture(device: view.device!, name: "mobile-overlay")
        } catch {
            fatalError("Error: Can not load render pass texture")
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
