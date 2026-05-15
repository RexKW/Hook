//
//  InterestedFishState.swift
//  Hook
//
//  Created by Christianto Elvern Haryanto on 13/05/26.
//

import GameplayKit
import SpriteKit

class InterestedFishState: GKState {
    unowned let stateComp: StateComponent
    
    init(component: StateComponent) {
        self.stateComp = component
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == SwimFishState.self ||
        stateClass == NibbleFishState.self ||
        stateClass == HookedFishState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        guard
            let fish = stateComp.entity as? FishEntity,
            let node = fish.component(ofType: GKSKNodeComponent.self)?.node,
            let hookPosition = stateComp.hookPosition
        else {
            stateComp.stateMachine.enter(SwimFishState.self)
            return
        }
        
        fish.component(ofType: FishMovementComponent.self)?.moveSpeed = 0
        node.removeAllActions()
        node.zRotation = 0
        node.zPosition = 900
        
        let approachPoint = CGPoint(
            x: hookPosition.x + 42,
            y: hookPosition.y - 18
        )
        face(node, toward: approachPoint.x)
        
        node.run(
            SKAction.sequence([
                SKAction.move(
                    to: approachPoint,
                    duration: stateComp.approachDuration
                ),
                SKAction.run { [weak self] in
                    self?.stateComp.stateMachine.enter(NibbleFishState.self)
                }
            ]),
            withKey: "interestedFish"
        )
    }
    
    override func willExit(to nextState: GKState) {
        stateComp.entity?
            .component(ofType: GKSKNodeComponent.self)?
            .node
            .removeAction(forKey: "interestedFish")
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
