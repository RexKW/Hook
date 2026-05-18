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
        
        let normalSpeed = fish.component(ofType: FishMovementComponent.self)?.moveSpeed ?? 100
        fish.component(ofType: FishMovementComponent.self)?.moveSpeed = 0
        node.removeAllActions()
        node.zRotation = 0
        node.zPosition = 900
        
        let approachPoint = CGPoint(
            x: hookPosition.x + 42,
            y: hookPosition.y - 18
        )
        face(node, toward: approachPoint.x)
        let approachDistance = distance(
            from: node.position,
            to: approachPoint
        )
        let approachDuration = TimeInterval(
            approachDistance / max(normalSpeed, 1)
        )
        
        node.run(
            SKAction.sequence([
                SKAction.move(
                    to: approachPoint,
                    duration: approachDuration
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
    
    private func distance(
        from start: CGPoint,
        to end: CGPoint
    ) -> CGFloat {
        let dx = end.x - start.x
        let dy = end.y - start.y
        return sqrt(dx * dx + dy * dy)
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
