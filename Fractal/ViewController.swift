//
//  ViewController.swift
//  metalFirstApp
//
//  Created by Мишаня on 13/04/2019.
//  Copyright © 2019 Мишаня. All rights reserved.
//

import UIKit
import MetalKit

enum Colors{
    static let green = MTLClearColor(red: 0.0,
                                     green: 0.4,
                                     blue: 0.21,
                                     alpha: 1.0)
}

class ViewController: UIViewController {
    
    var metalView: MTKView{
        return view as! MTKView
    }
    
    var renderer: Renderer!
    var zoomLocation: CGPoint! // coordinates in the midle of fingers when zoom began
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        metalView.device = MTLCreateSystemDefaultDevice()
        metalView.clearColor = Colors.green
        renderer = Renderer(device: metalView.device!)
        metalView.delegate = renderer
        
        //Setting up gestures
        addPanGesture()
        addPinchGesture()
        
    }
    
    func addPanGesture(){
        let pan = UIPanGestureRecognizer(target: self, action: #selector(fingerRotation(_:)))
        metalView.addGestureRecognizer(pan)
    }
    
    func addPinchGesture(){
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(fingerZoom(_:)))
        metalView.addGestureRecognizer(pinch)
    }
    
    @objc func fingerRotation(_ sender: UIPanGestureRecognizer){
        if sender.state == .began || sender.state == .changed{
            print(Float(sender.translation(in: metalView).x))
            renderer.constants.deltaX += 2 * Float(sender.translation(in: metalView).x) / renderer.constants.zoom / 320
            renderer.constants.deltaY += 2 * Float(sender.translation(in: metalView).y) / renderer.constants.zoom / 320
            sender.setTranslation(CGPoint.zero, in: metalView) // this Stops fracal where pan stopped without more movement
        }
        
    }
    
    
    
    @objc func fingerZoom(_ sender: UIPinchGestureRecognizer){
        
        
        if sender.state == .began{
            let firstTouch = sender.location(ofTouch: 0, in: metalView)
            let secondTouch = sender.location(ofTouch: 1, in: metalView)
            print(firstTouch, secondTouch)
            zoomLocation = CGPoint(x: abs(firstTouch.x + secondTouch.x) / 2,
                               y: abs(firstTouch.y + secondTouch.y) / 2)
            print(zoomLocation)
        }
        print(sender.scale)
        if sender.state == .began || sender.state == .changed{
            if sender.scale > 1{
                renderer.constants.zoom +=  0.04 * Float(sender.scale) * renderer.constants.zoom
                transformCoordinates(location: zoomLocation, isZooming: true)
                //transformCoordinates(withZoom: renderer.constants, isPositive: true)
            }else{
                renderer.constants.zoom -= 0.04 * (2 - Float(sender.scale)) * renderer.constants.zoom
                transformCoordinates(location: zoomLocation, isZooming: false)
                //transformCoordinates(withZoom: renderer.constants, isPositive: false)
            }
            
        }
    }
    
    func transformCoordinates(location: CGPoint, isZooming: Bool){
        let deltaX = 160 - location.x
        let deltaY = 284 - location.y
        print(renderer.constants.zoom)
        
        //print(renderer.constants.deltaX)
        if isZooming{
            renderer.constants.deltaX += 0.2 * Float(deltaX)  / renderer.constants.zoom  / 320
            renderer.constants.deltaY += 0.2 * Float(deltaY)   / renderer.constants.zoom / 320
        }else{
            if renderer.constants.zoom < 0.1{
                return
            }
            renderer.constants.deltaX -= 0.2 * Float(deltaX)  / renderer.constants.zoom  / 320
            renderer.constants.deltaY -= 0.2 * Float(deltaX)  / renderer.constants.zoom  / 320
        }
        //print(renderer.constants.deltaX, "is changed value")
    }
    
}

