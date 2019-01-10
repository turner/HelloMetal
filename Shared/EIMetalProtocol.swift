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
    func getPrimitiveType() -> MTLPrimitiveType
    func getIndexCount() -> Int
    func getIndexType() -> MTLIndexType
    func getIndexBuffer() -> MTLBuffer
    func getVertexDescriptor() -> MTLVertexDescriptor?
}
