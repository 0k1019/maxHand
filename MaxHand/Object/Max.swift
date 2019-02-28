//
//  Max.swift
//  knowWhere
//
//  Created by 권영호 on 15/01/2019.
//  Copyright © 2019 0ho_kwon. All rights reserved.
//

import Foundation
import SceneKit

class Max: SCNNode {
    var animating: Bool = false
    let patrolDistance: Float = 6
    var walking: Bool = false
    override init(){
        super.init()
        self.addChildNode(loadedContentForAsset(named: "max", directory: "character"))
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func animate() {
        if animating{return}
        animating = true
        let rotateOne = SCNAction.rotateBy(x: 0, y: .pi * 2, z: 0, duration: 1.0)
        
        let backwards = rotateOne.reversed()
        let rotateSequence = SCNAction.sequence([rotateOne, backwards])
        let repeatFoever = SCNAction.repeatForever(rotateSequence)
        
        runAction(repeatFoever)
    }
    func patrol(targetPos: SCNVector3){
        let distanceToTarget = targetPos.distance(receiver: self.position)
        
        if distanceToTarget < patrolDistance{
            removeAllActions()
            animating = false
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.20
            look(at: targetPos)
            SCNTransaction.commit()
        } else {
            if !animating{
                animate()
            }
        }
    }
    
    func frontCamera(cameraTransform: simd_float4x4){
        let cameraPosition = SCNVector3(cameraTransform.columns.3.x, cameraTransform.columns.3.y, cameraTransform.columns.3.z)
        let distanceToTarget = cameraPosition.distance(receiver: self.position)
        print("max.position")
        print(self.position)
        print("camera.position")
        print(cameraPosition)
        print("distanceToTarget")
        print(distanceToTarget)

        self.position = maxPosition(cameraTransform: cameraTransform)
    }
    
    private func maxPosition(cameraTransform: simd_float4x4) -> SCNVector3{
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -5.0
        let transform = cameraTransform * translation
        let position = SCNVector3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
        return position
    }
    
    func turnAround(){
        if walking{ return }
        walking = true
        let rotateHalf = SCNAction.rotateBy(x: 0, y: .pi, z: 0, duration: 0)
        runAction(rotateHalf)
    }
    
}
