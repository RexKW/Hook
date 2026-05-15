//
//  NibbleFishState.swift
//  Hook
//
//  Created by Christianto Elvern Haryanto on 13/05/26.
//

import GameplayKit
import SpriteKit

class NibbleFishState: GKState {
    unowned let stateComp: StateComponent
    
    init(component: StateComponent) {
        self.stateComp = component
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == InterestedFishState.self ||
        stateClass == SwimFishState.self ||
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
        
        let circleLeft = CGPoint(
            x: hookPosition.x - 34,
            y: hookPosition.y - 24
        )
        let circleRight = CGPoint(
            x: hookPosition.x + 34,
            y: hookPosition.y - 18
        )
        
        node.run(
            SKAction.sequence([
                SKAction.run { [weak self, weak node] in
                    guard let node else { return }
                    self?.face(node, toward: circleLeft.x)
                },
                SKAction.move(to: circleLeft, duration: stateComp.hesitateDuration / 3),
                SKAction.run { [weak self, weak node] in
                    guard let node else { return }
                    self?.face(node, toward: circleRight.x)
                },
                SKAction.move(to: circleRight, duration: stateComp.hesitateDuration / 3),
                SKAction.run { [weak self, weak node] in
                    guard let node else { return }
                    self?.face(node, toward: hookPosition.x)
                },
                SKAction.wait(forDuration: stateComp.hesitateDuration / 3),
                SKAction.run { [weak self] in
                    self?.resolveBite(for: fish)
                }
            ]),
            withKey: "nibbleFish"
        )
    }
    
    override func willExit(to nextState: GKState) {
        stateComp.entity?
            .component(ofType: GKSKNodeComponent.self)?
            .node
            .removeAction(forKey: "nibbleFish")
    }
    
    private func resolveBite(for fish: FishEntity) {
        let elapsedTime = currentElapsedTime()
        let shouldForceCatch = elapsedTime >= stateComp.guaranteedCatchDelay
        let didBite = shouldForceCatch || TestCatchProbability.didCatch(
            fish: fish,
            boatPower: stateComp.hookPower
        )
        
        if didBite {
            stateComp.stateMachine.enter(HookedFishState.self)
        } else {
            swimAway(fish)
        }
    }
    
    private func swimAway(_ fish: FishEntity) {
        guard
            let node = fish.component(ofType: GKSKNodeComponent.self)?.node,
            let hookPosition = stateComp.hookPosition
        else {
            stateComp.stateMachine.enter(SwimFishState.self)
            return
        }
        
        let swimDirection: CGFloat = node.position.x >= hookPosition.x ? 1 : -1
        let awayPoint = CGPoint(
            x: node.position.x + swimDirection * 180,
            y: node.position.y + CGFloat.random(in: -40...40)
        )
        face(node, toward: awayPoint.x)
        
        node.run(
            SKAction.sequence([
                SKAction.move(to: awayPoint, duration: 0.6),
                SKAction.run { [weak self] in
                    guard let self else { return }
                    self.restoreSwimming(for: fish)
                    self.stateComp.onFailed?(fish)
                    self.stateComp.stateMachine.enter(SwimFishState.self)
                }
            ]),
            withKey: "nibbleFail"
        )
    }
    
    private func restoreSwimming(for fish: FishEntity) {
        guard let movement = fish.component(ofType: FishMovementComponent.self) else {
            return
        }
        
        movement.moveSpeed = 180 / max(movement.weight, 1)
        movement.direction = CGVector(
            dx: Bool.random() ? 1 : -1,
            dy: CGFloat.random(in: movement.verticalDriftRange)
        )
    }
    
    private func currentElapsedTime() -> TimeInterval {
        guard let sessionStartTime = stateComp.sessionStartTime else {
            return 0
        }
        
        return CACurrentMediaTime() - sessionStartTime
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
