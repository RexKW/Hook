//
//  MovementSystem.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//

import GameplayKit
import SpriteKit

class MovementSystem: GKComponent {
    
    func update(deltaTime seconds: TimeInterval, rodTip: CGPoint) {
            // node from GKSKNodeComponent
            guard let node = entity?.component(ofType: GKSKNodeComponent.self)?.node,
                  let move = entity?.component(ofType: MovementComponent.self),
                  let state = entity?.component(ofType: StateComponent.self),
                  let input = entity?.component(ofType: InputComponent.self) else { return }
            
            let limit = state.boatTier.rawValue

            
            let stateMachine = (entity as? HookEntity)?.stateMachine

            if state.currentState == .waiting {
                
                if input.isHolding && node.position.y > limit {
                    node.position.y -= (move.dropSpeed * CGFloat(seconds))
                }
                
                if node.position.y < limit {
                    node.position.y = limit
                }
            
                if input.isTapped {
                    stateMachine?.enter(ReelingState.self)
                }
                
            } else if state.currentState == .reeling {

                node.position.y += (move.reelSpeed * CGFloat(seconds))
                
                let diffX = rodTip.x - node.position.x
                node.position.x += diffX * 0.1
                
                if node.position.y >= rodTip.y {
                    node.position = rodTip
                    stateMachine?.enter(IdleState.self)
                }
            }
        
    }
}
