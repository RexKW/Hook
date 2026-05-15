//
//  HookedFishState.swift
//  Hook
//
//  Created by Christianto Elvern Haryanto on 13/05/26.
//

import GameplayKit
import SpriteKit

class HookedFishState: GKState {
    unowned let stateComp: StateComponent
    
    init(component: StateComponent) {
        self.stateComp = component
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return false
    }
    
    override func didEnter(from previousState: GKState?) {
        guard
            let fish = stateComp.entity as? FishEntity,
            let node = fish.component(ofType: GKSKNodeComponent.self)?.node,
            let hookPosition = stateComp.hookPosition
        else {
            return
        }
        
        if let movement = fish.component(ofType: FishMovementComponent.self) {
            movement.isHooked = true
            movement.moveSpeed = 0
        }
        
        node.removeAllActions()
        node.zPosition = 900
        face(node, toward: hookPosition.x)
        
        node.run(
            SKAction.sequence([
                SKAction.move(to: hookPosition, duration: 0.25),
                SKAction.run { [weak self] in
                    guard let self else { return }
                    node.zRotation = .pi / 2
                    self.stateComp.onHooked?(fish)
                }
            ]),
            withKey: "hookedFish"
        )
    }
    
    private func face(
        _ node: SKNode,
        toward targetX: CGFloat
    ) {
        if targetX > node.position.x {
            node.xScale = abs(node.xScale)
        } else if targetX < node.position.x {
            node.xScale = -abs(node.xScale)
        }
    }
}
