//
//  EIMetalProtocol.swift
//  Hello
//
//  Created by Douglass Turner on 12/1/18.
//  Copyright © 2018 Elastic Image Software. All rights reserved.
//

import MetalKit
import GLKit
protocol EIMetalProtocol {
    func getVertexMetalBuffer() -> MTLBuffer
    func getMetallicTransformMetalBuffer() -> MTLBuffer
    func getPrimitiveType() -> MTLPrimitiveType
    func getIndexCount() -> Int
    func getIndexType() -> MTLIndexType
    func getIndexBuffer() -> MTLBuffer
    mutating func update(camera:EICamera, arcBall:EIArcball, transformer:() -> GLKMatrix4)
}
