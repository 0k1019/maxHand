//
//  Node+Extensions.swift
//  ARWalkthrough
//
//  Created by Wyszynski, Daniel on 2/18/18.
//  Copyright © 2018 Nike, Inc. All rights reserved.
//

import SceneKit

extension SCNNode {

    func topmost(parent: SCNNode? = nil, until: SCNNode) -> SCNNode {
        if let pNode = self.parent {
             return pNode == until ? self : pNode.topmost(parent: pNode, until: until)
        } else {
            return self
        }

    }
}
