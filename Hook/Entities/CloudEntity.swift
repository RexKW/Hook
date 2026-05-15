//
//  CloudEntity.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 14/05/26.
//

import GameplayKit
import SpriteKit

class CloudEntity: GKEntity {
    init(node: SKSpriteNode){
        super.init()
        
        node.texture?.filteringMode = .nearest
        addComponent(GKSKNodeComponent(node: node))
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
