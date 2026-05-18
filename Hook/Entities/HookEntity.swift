//
//  HookEntity.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//

import GameKit
import SpriteKit

class HookEntity: GKEntity {
    init(node: SKSpriteNode){
        super.init()
        
        //MARK: - Visual Initialization
        node.texture?.filteringMode = .nearest //To render the fish without causing the image to breakdown
        addComponent(GKSKNodeComponent(node: node)) //Links GameplayKit with SpriteKit
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
