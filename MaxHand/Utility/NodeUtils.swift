//
//  NodeUtils.swift
//  knowWhere
//
//  Created by 권영호 on 15/01/2019.
//  Copyright © 2019 0ho_kwon. All rights reserved.
//

import Foundation
import SceneKit

func loadedContentForAsset(named resourceName: String, directory: String) -> SCNNode {
    
    guard let url = Bundle.main.url(forResource: resourceName, withExtension: "scn", subdirectory: "art.scnassets/\(directory)") else {
        return SCNNode()
    }
    guard let node = SCNReferenceNode(url: url) else{
        return SCNNode()
    }
    node.load()
    
    return node
}
