//
//  HookedFishState.swift
//  Hook
//
//  Created by Christianto Elvern Haryanto on 13/05/26.
//

import GameplayKit
import SpriteKit

class HookedFishState: GKState {
    unowned let stateComp: FishStateComponent
    
    init(component: FishStateComponent) {
        self.stateComp = component
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == SwimFishState.self
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
        face(node, toward: hookPosition.x)
        
        node.run(
            SKAction.sequence([
                SKAction.move(to: hookPosition, duration: 0.25),
                SKAction.run { [weak self] in
                    guard let self else { return }
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
        let tiltAngle: CGFloat = 0.35
        
        if targetX > node.position.x {
            node.xScale = -abs(node.xScale)
            node.zRotation = -tiltAngle
        } else if targetX < node.position.x {
            node.xScale = abs(node.xScale)
            node.zRotation = tiltAngle
        }
    }
}
