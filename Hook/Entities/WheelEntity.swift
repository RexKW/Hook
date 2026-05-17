//
//  WheelEntity.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 12/05/26.
//

import GameplayKit
import SpriteKit

class WheelEntity: GKEntity {
    init(node: SKSpriteNode){
        super.init()
        
        node.texture?.filteringMode = .nearest
        addComponent(GKSKNodeComponent(node: node))
        
        addComponent(ReelingSystem())
        addComponent(ReelingComponent())
        
        addComponent(ReelingVisualSystem())
        addComponent(ReelingVisualComponent())
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
