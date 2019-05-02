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
//    var animating: Bool = false
//    let patrolDistance: Float = 6
//    var walking: Bool = false
    var spining: Bool = false
    static private let speedFactor: CGFloat = 2.0
    static private let initialPosition = float3(0.1, -0.2, 0)

    // Character handle
//    private var characterNode: SCNNode! // top level node
    private var characterOrientation: SCNNode! // the node to rotate to orient the character
    private var model: SCNNode! // the model loaded from the character file
    
    private var directionAngle: CGFloat = 0.0 {
        didSet {
            characterOrientation.runAction(
                SCNAction.rotateTo(x: 0.0, y: directionAngle, z: 0.0, duration: 0.1, usesShortestUnitArc:true))
        }
    }
    
    var isWalking: Bool = false {
        didSet {
            if oldValue != isWalking {
                // Update node animation.
                if isWalking {
                    model.animationPlayer(forKey: "walk")?.play()
                } else {
                    model.animationPlayer(forKey: "walk")?.stop(withBlendOutDuration: 0.2)
                }
            }
        }
    }
    
    var isJumping: Bool = false {
        didSet {
            if oldValue != isJumping {
                if isJumping {
                    model.animationPlayer(forKey: "jump")?.play()
                } else {
                    model.animationPlayer(forKey: "jump")?.stop()
                }
            }
        }
    }
    
    override init(){
        super.init()
        loadCharacter()
        loadAnimations()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadCharacter() {
        let scene = SCNScene(named: "art.scnassets/character/max.scn")!
        model = scene.rootNode.childNode(withName: "Max_rootNode", recursively: true)
        /* setup character hierarchy
         Max
         |_orientationNode
         |_model
         */
        
        self.name = "character"
        self.simdPosition = Max.initialPosition
        
        characterOrientation = SCNNode()
        self.addChildNode(characterOrientation)
        characterOrientation.addChildNode(model)
        self.model.enumerateChildNodes { (childNode, nil) in
            print(childNode)
        }
        
    }
    
    
    private func loadAnimations() {
        
        let idleAnimation = Max.loadAnimation(fromSceneNamed: "art.scnassets/character/max_idle.scn")
        model.addAnimationPlayer(idleAnimation, forKey: "idle")
        idleAnimation.play()
        
        let walkAnimation = Max.loadAnimation(fromSceneNamed: "art.scnassets/character/max_walk.scn")
        walkAnimation.speed = Max.speedFactor
        walkAnimation.stop()
        model.addAnimationPlayer(walkAnimation, forKey: "walk")
        
        let jumpAnimation = Max.loadAnimation(fromSceneNamed: "art.scnassets/character/max_jump.scn")
        jumpAnimation.animation.isRemovedOnCompletion = false
        jumpAnimation.speed = 1.5
        jumpAnimation.stop()
        model.addAnimationPlayer(jumpAnimation, forKey: "jump")
        
        let spinAnimation = Max.loadAnimation(fromSceneNamed: "art.scnassets/character/max_spin.scn")
        spinAnimation.animation.isRemovedOnCompletion = false
        spinAnimation.speed = 1.5
        spinAnimation.stop()
        model.addAnimationPlayer(spinAnimation, forKey: "spin")
        
        let hiphopAnimation = Max.loadAnimation(fromSceneNamed: "art.scnassets/character/hiphopani.scn")
        hiphopAnimation.animation.isRemovedOnCompletion = false
        hiphopAnimation.speed = 1.5
        hiphopAnimation.stop()
        model.addAnimationPlayer(hiphopAnimation, forKey: "hiphop")
        
    }
    
//    func animate() {
//        if animating{return}
//        animating = true
//        let rotateOne = SCNAction.rotateBy(x: 0, y: .pi * 2, z: 0, duration: 1.0)
//
//        let backwards = rotateOne.reversed()
//        let rotateSequence = SCNAction.sequence([rotateOne, backwards])
//        let repeatFoever = SCNAction.repeatForever(rotateSequence)
//
//        runAction(repeatFoever)
//    }
//    func patrol(targetPos: SCNVector3){
//        let distanceToTarget = targetPos.distance(receiver: self.position)
//
//        if distanceToTarget < patrolDistance{
//            removeAllActions()
//            animating = false
//            SCNTransaction.begin()
//            SCNTransaction.animationDuration = 0.20
//            look(at: targetPos)
//            SCNTransaction.commit()
//        } else {
//            if !animating{
//                animate()
//            }
//        }
//    }
//
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
    
//    func turnAround(){
//        if walking{ return }
//        walking = true
//        let rotateHalf = SCNAction.rotateBy(x: 0, y: .pi, z: 0, duration: 0)
//        runAction(rotateHalf)
//    }
    func spin(){
        model.animationPlayer(forKey: "spin")?.play()
    }
    
    
    func maxCome(camera: SCNVector3){
        removeAllActions()
        SCNTransaction.begin()
        self.isWalking = true
//        self.walk()
//        self.position = SCNVector3Make(camera.x, self.position.y, camera.z)
        let cameraPosition = SCNVector3Make(camera.x, camera.y, camera.z)
        let movePosition = SCNVector3Make(camera.x, self.position.y, camera.z)
        let move = SCNAction.move(to: movePosition, duration: 2)
        self.characterOrientation.look(at: cameraPosition)
        self.runAction(move)
        SCNTransaction.commit()
    }
    
    class func loadAnimation(fromSceneNamed sceneName: String) -> SCNAnimationPlayer {
        
        let scene = SCNScene( named: sceneName )!
        // find top level animation
        var animationPlayer: SCNAnimationPlayer! = nil
        scene.rootNode.enumerateChildNodes { (child, stop) in
            if !child.animationKeys.isEmpty {
                animationPlayer = child.animationPlayer(forKey: child.animationKeys[0])
                stop.pointee = true
            }
        }
        return animationPlayer
        
    }
}
