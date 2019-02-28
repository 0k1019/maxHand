//
//  Character.swift
//  knowWhere
//
//  Created by 권영호 on 14/01/2019.
//  Copyright © 2019 0ho_kwon. All rights reserved.
//

import Foundation
import SceneKit
import simd

class Character: NSObject {

    static private let speedFactor: CGFloat = 2.0
    static private let stepsCount = 10
    
    private let initialPosition = float3(0.1, -0.2, 0)
    
    // some constants
    static private let gravity = Float(0.004)
    static private let jumpImpulse = Float(0.1)
    static private let minAltitude = Float(-10)
    static private let enableFootStepSound = true
    static private let collisionMargin = Float(0.04)
    static private let modelOffset = float3(0, -collisionMargin, 0)
    static private let collisionMeshBitMask = 8
    
    // Character handle
    private var characterNode: SCNNode! // top level node
    private var characterOrientation: SCNNode! // the node to rotate to orient the character
    private var model: SCNNode! // the model loaded from the character file
    
    // Physics
    private var characterCollisionShape: SCNPhysicsShape?
    private var collisionShapeOffsetFromModel = float3.zero
    private var downwardAcceleration: Float = 0
    
    // void playing the step sound too often
    private var lastStepFrame: Int = 0
    private var frameCounter: Int = 0
    
    // Direction
    private var previousUpdateTime: TimeInterval = 0
    private var controllerDirection = float2.zero
    
    // states
    private var attackCount: Int = 0
    private var lastHitTime: TimeInterval = 0
    
    private var shouldResetCharacterPosition = false
    
    // actions
    var isJump: Bool = false
    var direction = float2()
    var physicsWorld: SCNPhysicsWorld?
    
    // MARK: - Initialization
    init(scene: SCNScene) {
        super.init()
    }
    
    private func loadCharacter() {
        /// Load character from external file
        let scene = SCNScene( named: "Art.scnassets/character/max.scn")!
        model = scene.rootNode.childNode( withName: "Max_rootNode", recursively: true)
        model.simdPosition = Character.modelOffset
        
        /* setup character hierarchy
         character
         |_orientationNode
         |_model
         */
        characterNode = SCNNode()
        characterNode.name = "character"
        //characterNode.simdPosition = Character.initialPosition
        
        characterOrientation = SCNNode()
        characterNode.addChildNode(characterOrientation)
        characterOrientation.addChildNode(model)
        
        let collider = model.childNode(withName: "collider", recursively: true)!
        //collider.physicsBody?.collisionBitMask = Int(([ .enemy, .trigger, .collectable ] as Bitmask).rawValue)
        
        // Setup collision shape
        let (min, max) = model.boundingBox
        let collisionCapsuleRadius = CGFloat(max.x - min.x) * CGFloat(0.4)
        let collisionCapsuleHeight = CGFloat(max.y - min.y)
        
        let collisionGeometry = SCNCapsule(capRadius: collisionCapsuleRadius, height: collisionCapsuleHeight)
        characterCollisionShape = SCNPhysicsShape(geometry: collisionGeometry, options:[.collisionMargin: Character.collisionMargin])
        collisionShapeOffsetFromModel = float3(0, Float(collisionCapsuleHeight) * 0.51, 0.0)
    }
    
    
}
