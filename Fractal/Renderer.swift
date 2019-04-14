//
//  Renderer.swift
//  metalFirstApp
//
//  Created by Мишаня on 13/04/2019.
//  Copyright © 2019 Мишаня. All rights reserved.
//

import MetalKit
import Foundation

class Renderer: NSObject{
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    
    var vertices: [Vertex] = [
        Vertex(position: float3(-1, 1, 0), // vertex 0
               color: float4(1, 0, 0, 1)),
        Vertex(position: float3(-1,-1,0), // vertex 1
               color: float4(0, 1, 0, 1)),
        Vertex(position: float3(1, -1, 0), // vertex 2
               color: float4(0,0,1,1)),
        Vertex(position: float3(1, 1, 0), // vertex 3
               color: float4(1, 0, 1, 1))
//
//        -1,  1, 0,  // vertex0
//        -1, -1, 0,  // vertex1
//         1, -1, 0,  // vertex2
//         1,  1, 0   // vertex3
    ]
    
    var indices: [UInt16] = [
        0, 1, 2,
        2, 3, 0
    ]
    
    var constants: Constants
    
    var pipeLineState: MTLRenderPipelineState?
    var vertexBuffer: MTLBuffer?
    var indexBuffer: MTLBuffer?
    
    init(device: MTLDevice){
        self.device = device
        commandQueue = device.makeCommandQueue()!
        constants = Constants()
        super.init()
        buildModel()
        buildPipeLine()
    }
    
    private func buildModel(){
        vertexBuffer = device.makeBuffer(bytes: vertices,
                                         length: vertices.count * MemoryLayout<Vertex>.stride,
                                         options: [])// something like malloc
        indexBuffer = device.makeBuffer(bytes: indices,
                                        length: indices.count * MemoryLayout<UInt16>.size,
                                        options: [])
        
    }
    
    private func buildPipeLine(){
        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "vertex_shader")
        let fragmentFunction = library?.makeFunction(name: "fragment_shader")
        //let kernelFunction = library?.makeFunction(name: "myKernelFunc") // There is no kernels in the project, just writed to remember or to remind later
        
        let pipeLineDescriptor = MTLRenderPipelineDescriptor()
        pipeLineDescriptor.vertexFunction = vertexFunction
        pipeLineDescriptor.fragmentFunction = fragmentFunction
        pipeLineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].offset = MemoryLayout<float3>.stride // colors memory in struct lies after coordinates
        vertexDescriptor.attributes[1].bufferIndex = 0
        
        vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride
        
        pipeLineDescriptor.vertexDescriptor = vertexDescriptor
        
        
        
        do{
            pipeLineState = try device.makeRenderPipelineState(descriptor:
                pipeLineDescriptor)
            //pipeLineState = device.makeComputePipelineState(function: kernelFunction)
        }catch{
            print(error.localizedDescription)
        }
        
    }
}

extension Renderer: MTKViewDelegate{
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
            let pipeLineState = pipeLineState,
            let indexBuffer = indexBuffer,
            let descriptor = view.currentRenderPassDescriptor else {return}
        let commandBuffer = commandQueue.makeCommandBuffer()
        
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor:
            descriptor)
        
        
        commandEncoder?.setVertexBytes(&constants,
                                       length: MemoryLayout<Constants>.stride,
                                       index: 1) // put the struct in the 1st buffer that vertex_shader func will call in parameter constants
        commandEncoder?.setFragmentBytes(&constants,
                                         length: MemoryLayout<Constants>.stride,
                                         index: 0)
        commandEncoder?.setRenderPipelineState(pipeLineState)
        commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
//        commandEncoder?.drawPrimitives(type: .triangle,
//                                       vertexStart: 0,
//                                       vertexCount: vertices.count)
        commandEncoder?.drawIndexedPrimitives(type: .triangle,
                                              indexCount: indices.count,
                                              indexType: .uint16,
                                              indexBuffer: indexBuffer,
                                              indexBufferOffset: 0)
        
        commandEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
    
    
}
