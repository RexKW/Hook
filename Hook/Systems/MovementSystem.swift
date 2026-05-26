//
//  MovementSystem.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//

import GameplayKit
import SpriteKit

class MovementSystem: GKComponent {
    
    func update(deltaTime: TimeInterval, rodTip: CGPoint) {
            // node from GKSKNodeComponent
            guard let node = entity?.component(ofType: GKSKNodeComponent.self)?.node,
                  let move = entity?.component(ofType: MovementComponent.self),
                  let state = entity?.component(ofType: StateComponent.self),
                  let input = entity?.component(ofType: InputComponent.self) else { return }
            
            let limit = state.boatTier.rawValue
            
            let stateMachine = (entity as? HookEntity)?.stateMachine
        
            let calculatedDropSpeed = move.dropSpeed(for: state.currentBoatLevel)
        
        if state.stateMachine.currentState is CastingState {
            
            if input.isHolding {
                // 1. Move the hook deeper the longer they hold
                let speed = calculatedDropSpeed > 0 ? calculatedDropSpeed : 800.0
                node.position.y -= (speed * CGFloat(deltaTime))
                
                // Optional: Put a hard limit so it doesn't go below the sea floor
                if node.position.y <= limit{
                    node.position.y = limit
                    print("Reached bottom for current tier: \(limit)")
                    state.stateMachine.enter(WaitingState.self)
                }
                
            } else {
                // 2. The player let go! Stop dropping and start waiting for a fish.
                print("✅ Masuk ke Waiting State at depth: \(node.position.y)")
                state.stateMachine.enter(WaitingState.self)
            }
        }
        
        if state.stateMachine.currentState is WaitingState {
            if input.isTapped {
                stateMachine?.enter(CancelState.self)
                
            }
        }
        
        if state.stateMachine.currentState is CancelState {
            if node.position.y >= -847 {
                node.position.y = -847
                stateMachine?.enter(IdleState.self)
            }
            
        }

        if state.stateMachine.currentState is IdleState {
                
                if input.isHolding && node.position.y > limit {
                    print("casting \(node.position.y)")
                    node.position.y -= (calculatedDropSpeed * CGFloat(deltaTime))
                }
                
                if node.position.y < limit {
                    node.position.y = limit
                }
            
            
                
                
        }
        
        if state.stateMachine.currentState is ReelingState {
                
                if node.position.y >= -847 {
                    node.position.y = -847
                    stateMachine?.enter(IdleState.self)
                }
            }
        
    }
}
