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
    var status: Int = 0
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
                    model.animationPlayer(forKey: "walk")?.stop(withBlendOutDuration: 2)
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
    static private let stepsCount = 10

    // Sound effects
    private var aahSound: SCNAudioSource!
    private var ouchSound: SCNAudioSource!
    private var hitSound: SCNAudioSource!
    private var hitEnemySound: SCNAudioSource!
    private var explodeEnemySound: SCNAudioSource!
    private var catchFireSound: SCNAudioSource!
    private var jumpSound: SCNAudioSource!
    private var attackSound: SCNAudioSource!
    private var steps = [SCNAudioSource](repeating: SCNAudioSource(), count: Max.stepsCount )
    
    override init(){
        super.init()
        loadCharacter()
        loadAnimations()
        loadSounds()
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
        
//        let idleAnimation = Max.loadAnimation(fromSceneNamed: "art.scnassets/character/max_idle.scn")
//        model.addAnimationPlayer(idleAnimation, forKey: "idle")
//        idleAnimation.play()
        
        let walkAnimation = Max.loadAnimation(fromSceneNamed: "art.scnassets/character/max_walk.scn")
        walkAnimation.speed = Max.speedFactor
        walkAnimation.stop()
        walkAnimation.animation.animationEvents = [
            SCNAnimationEvent(keyTime: 0.1, block: { _, _, _ in self.playFootStep() }),
            SCNAnimationEvent(keyTime: 0.6, block: { _, _, _ in self.playFootStep() })
        ]
        model.addAnimationPlayer(walkAnimation, forKey: "walk")
        
        let jumpAnimation = Max.loadAnimation(fromSceneNamed: "art.scnassets/character/max_jump.scn")
        jumpAnimation.animation.isRemovedOnCompletion = false
        jumpAnimation.speed = 1.5
        jumpAnimation.stop()
        jumpAnimation.animation.animationEvents = [SCNAnimationEvent(keyTime: 0, block: { _, _, _ in self.playJumpSound() })]
        model.addAnimationPlayer(jumpAnimation, forKey: "jump")
        
        let spinAnimation = Max.loadAnimation(fromSceneNamed: "art.scnassets/character/max_spin.scn")
        spinAnimation.animation.isRemovedOnCompletion = false
        spinAnimation.speed = 1.5
        spinAnimation.stop()
        spinAnimation.animation.animationEvents = [SCNAnimationEvent(keyTime: 0, block: { _, _, _ in self.playAttackSound() })]

        model.addAnimationPlayer(spinAnimation, forKey: "spin")
        
        let hiphopAnimation = Max.loadAnimation(fromSceneNamed: "art.scnassets/character/hiphopani.scn")
        hiphopAnimation.animation.isRemovedOnCompletion = false
        hiphopAnimation.speed = 1.5
        hiphopAnimation.stop()
        model.addAnimationPlayer(hiphopAnimation, forKey: "hiphop")
        
    }
    
    private func loadSounds() {
        aahSound = SCNAudioSource( named: "audio/aah_extinction.mp3")!
        aahSound.volume = 1.0
        aahSound.isPositional = false
        aahSound.load()
        
        catchFireSound = SCNAudioSource(named: "audio/panda_catch_fire.mp3")!
        catchFireSound.volume = 5.0
        catchFireSound.isPositional = false
        catchFireSound.load()
        
        ouchSound = SCNAudioSource(named: "audio/ouch_firehit.mp3")!
        ouchSound.volume = 2.0
        ouchSound.isPositional = false
        ouchSound.load()
        
        hitSound = SCNAudioSource(named: "audio/hit.mp3")!
        hitSound.volume = 2.0
        hitSound.isPositional = false
        hitSound.load()
        
        hitEnemySound = SCNAudioSource(named: "audio/Explosion1.m4a")!
        hitEnemySound.volume = 2.0
        hitEnemySound.isPositional = false
        hitEnemySound.load()
        
        explodeEnemySound = SCNAudioSource(named: "audio/Explosion2.m4a")!
        explodeEnemySound.volume = 2.0
        explodeEnemySound.isPositional = false
        explodeEnemySound.load()
        
        jumpSound = SCNAudioSource(named: "audio/jump.m4a")!
        jumpSound.volume = 0.2
        jumpSound.isPositional = false
        jumpSound.load()
        
        attackSound = SCNAudioSource(named: "audio/attack.mp3")!
        attackSound.volume = 1.0
        attackSound.isPositional = false
        attackSound.load()
        
        for i in 0..<Max.stepsCount {
            steps[i] = SCNAudioSource(named: "audio/Step_rock_0\(UInt32(i)).mp3")!
            steps[i].volume = 0.5
            steps[i].isPositional = false
            steps[i].load()
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
        let cameraPosition = SCNVector3Make(camera.x, camera.y, camera.z)
        let maxPosition = makeMaxPositionBetween(Avec: cameraPosition, Bvec: self.position, By: 0.7)
        let movePosition = SCNVector3Make(maxPosition.x, self.position.y, maxPosition.z)
        let move = SCNAction.move(to: movePosition, duration: 2)
        self.maxHeadMove(look: cameraPosition)
        self.runAction(move)
        self.isWalking = false
        SCNTransaction.commit()
    }
    
    private func makeMaxPositionBetween(Avec: SCNVector3, Bvec: SCNVector3, By: Float) -> SCNVector3{
        var Dvec = Bvec - Avec
        Dvec = Dvec.normalize()
        let Cvec = Dvec * By + Avec
        return Cvec
    }
    
    func maxHeadMove(look: SCNVector3){
        self.enumerateChildNodes { (node, stop) in
            if (node.name == "Bip001_Head"){
                print("head")
                node.look(at: look)
                stop.pointee = true
            }
        }
    }
    
    func maxTailMove(locatio: SCNVector3){
        self.enumerateChildNodes { (node, stop) in
            if (node.name == "Bip001_Tail2"){
                print("tail")
                stop.pointee = true
            }
        }
    }
    
    func playFootStep() {
//        if groundNode != nil && isWalking { // We are in the air, no sound to play.
            // Play a random step sound.
            let randSnd: Int = Int(Float(arc4random()) / Float(RAND_MAX) * Float(Max.stepsCount))
            let stepSoundIndex: Int = min(Max.stepsCount - 1, randSnd)
            self.runAction(SCNAction.playAudio( steps[stepSoundIndex], waitForCompletion: false))
//        }
    }
    
    func playJumpSound() {
        self.runAction(SCNAction.playAudio(jumpSound, waitForCompletion: false))
    }
    
    func playAttackSound() {
        self.runAction(SCNAction.playAudio(attackSound, waitForCompletion: false))
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
