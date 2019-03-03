//
//  Fow.swift
//  knowWhere
//
//  Created by 권영호 on 15/01/2019.
//  Copyright © 2019 0ho_kwon. All rights reserved.
//

import Foundation
import SceneKit

struct MaxScene {
    var scene: SCNScene?
    init(){
        scene = SCNScene()
    }
    func addMax(position: SCNVector3) {
        guard let scene = self.scene else { return }
        let max = Max()
        max.position = position
        max.scale = SCNVector3(5,5,5)
        scene.rootNode.addChildNode(max)
    }
    func makeUpdateCameraPos(cameraTransform: simd_float4x4) {
        guard let scene = self.scene else { return }
        scene.rootNode.enumerateChildNodes({ (node, _) in
            if let max = node.topmost(until: scene.rootNode) as? Max {
                scene.rootNode.childNodes
//                max.patrol(targetPos: towards)
                max.frontCamera(cameraTransform: cameraTransform)
            }
        })
    }
    func addMaxByNodeAndVector(node: SCNNode, vector: SCNVector3){
        let max = Max()
        max.position = vector
        max.scale = SCNVector3(5,5,5)
        node.addChildNode(max)
    }
    
    func removeAllMax(){
        guard let scene = self.scene else { return }
        scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
    }
    
}
