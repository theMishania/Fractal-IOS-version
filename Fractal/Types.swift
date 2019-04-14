//
//  Types.swift
//  gradientMetalApp
//
//  Created by Мишаня on 14/04/2019.
//  Copyright © 2019 Мишаня. All rights reserved.
//

import simd

struct Vertex {
    var position: float3
    var color: float4
}

struct Constants{
    var deltaX: Float = 0.0
    var deltaY: Float = 0.0
    var zoom: Float = 0.8
}
