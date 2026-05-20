//
//  FishEntity.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//

import GameKit
import SpriteKit

class FishEntity: GKEntity {
    init(node: SKSpriteNode){
        super.init()
        
        //MARK: - Visual Initialization
        node.texture?.filteringMode = .nearest //To render the fish without causing the image to breakdown
        addComponent(GKSKNodeComponent(node: node)) //Links GameplayKit with SpriteKit
        //Let the entity own the sprite
        
        //MARK: - Movement Initialization
        //add movement component for fish
        addComponent(FishMovementComponent())
        addComponent(FishMovementSystem())
        addComponent(FishStateSystem())
        let stateComponent = FishStateComponent()
        addComponent(stateComponent)
        stateComponent.stateMachine.enter(SwimFishState.self)
        
//        //MARK: - Physics
//        if let body = node.physicsBody{
//            
//        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
