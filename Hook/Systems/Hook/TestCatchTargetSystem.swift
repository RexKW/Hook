//
//  TestCatchTargetSystem.swift
//  Hook
//
//  Created by OpenAI on 13/05/26.
//

import GameplayKit
import SpriteKit

class TestCatchTargetSystem {
    private let guaranteedCatchDelay: TimeInterval = 14.5
    private let approachDuration: TimeInterval = 1.1
    private let hesitateDuration: TimeInterval = 1.0
    private let maxCatchDistanceSquared: CGFloat = 300 * 300
    private let normalFishZPosition: CGFloat = 50
    private var sessionStartTime: TimeInterval?
    private var activeFish: FishEntity?
    private(set) var caughtFish: FishEntity?
    
    var hasCaughtFish: Bool {
        caughtFish != nil
    }
    
    func tryCatchFish(
        from fishEntities: [FishEntity],
        hookPosition: CGPoint,
        hookLayer: FishGenerator.SeaLayer,
        currentTime: TimeInterval,
        hookPower: CGFloat,
        onHooked: @escaping (FishEntity) -> Void,
        onFailed: @escaping (FishEntity) -> Void
    ) -> FishEntity? {
        guard caughtFish == nil else {
            return caughtFish
        }
        
        guard activeFish == nil else {
            return activeFish
        }
        
        if sessionStartTime == nil {
            sessionStartTime = currentTime
        }
        
        guard let targetFish = nearestFish(
            from: fishEntities,
            to: hookPosition,
            in: hookLayer
        ) else {
            return nil
        }
        
        activeFish = targetFish
        startInterestedState(
            targetFish,
            hookPosition: hookPosition,
            currentTime: currentTime,
            hookPower: hookPower,
            onHooked: onHooked,
            onFailed: onFailed
        )
        
        return targetFish
    }
    
    func resetCatchSession() {
        cancelActiveFishAttempt()
        sessionStartTime = nil
        activeFish = nil
        caughtFish = nil
    }
    
    private func cancelActiveFishAttempt() {
        guard let fish = activeFish ?? caughtFish else {
            return
        }
        
        if let node = fish.component(ofType: GKSKNodeComponent.self)?.node {
            node.removeAction(forKey: "interestedFish")
            node.removeAction(forKey: "nibbleFish")
            node.removeAction(forKey: "nibbleFail")
            node.removeAction(forKey: "hookedFish")
            node.zRotation = 0
            node.yScale = abs(node.yScale)
            node.zPosition = normalFishZPosition
        }
        
        if let movement = fish.component(ofType: FishMovementComponent.self) {
            movement.isHooked = false
            movement.moveSpeed = movement.baseMoveSpeed
            movement.direction = CGVector(
                dx: Bool.random() ? 1 : -1,
                dy: CGFloat.random(in: movement.verticalDriftRange)
            )
        }
        
        if let stateComponent = fish.component(ofType: FishStateComponent.self) {
            stateComponent.hookPosition = nil
            stateComponent.sessionStartTime = nil
            stateComponent.onHooked = nil
            stateComponent.onFailed = nil
            stateComponent.ignoreHookUntilTime = CACurrentMediaTime() + 1
            stateComponent.stateMachine.enter(SwimFishState.self)
        }
    }
    
    private func nearestFish(
        from fishEntities: [FishEntity],
        to hookPosition: CGPoint,
        in hookLayer: FishGenerator.SeaLayer
    ) -> FishEntity? {
        fishEntities
            .filter { fish in
                guard
                    let node = fish.component(ofType: GKSKNodeComponent.self)?.node,
                    let movement = fish.component(ofType: FishMovementComponent.self),
                    let state = fish.component(ofType: FishStateComponent.self),
                    node.parent != nil,
                    movement.layer == hookLayer,
                    state.ignoreHookUntilTime <= CACurrentMediaTime()
                else {
                    return false
                }
                
                return distanceSquared(
                    from: fish,
                    to: hookPosition
                ) <= maxCatchDistanceSquared
            }
            .min { firstFish, secondFish in
                distanceSquared(
                    from: firstFish,
                    to: hookPosition
                ) < distanceSquared(
                    from: secondFish,
                    to: hookPosition
                )
            }
    }
    
    private func startInterestedState(
        _ fish: FishEntity,
        hookPosition: CGPoint,
        currentTime: TimeInterval,
        hookPower: CGFloat,
        onHooked: @escaping (FishEntity) -> Void,
        onFailed: @escaping (FishEntity) -> Void
    ) {
        guard let stateComponent = fish.component(ofType: FishStateComponent.self) else {
            activeFish = nil
            return
        }
        
        stateComponent.hookPosition = hookPosition
        stateComponent.hookPower = hookPower
        stateComponent.sessionStartTime = currentTime
        stateComponent.onHooked = { [weak self] hookedFish in
            self?.caughtFish = hookedFish
            onHooked(hookedFish)
        }
        stateComponent.onFailed = { [weak self] failedFish in
            self?.activeFish = nil
            onFailed(failedFish)
        }
        stateComponent.stateMachine.enter(InterestedFishState.self)
    }
    
    private func startInterestSequence(
        _ fish: FishEntity,
        hookPosition: CGPoint,
        currentTime: TimeInterval,
        hookPower: CGFloat,
        onHooked: @escaping (FishEntity) -> Void,
        onFailed: @escaping (FishEntity) -> Void
    ) {
        guard let node = fish.component(
            ofType: GKSKNodeComponent.self
        )?.node else {
            activeFish = nil
            return
        }
        
        if let movement = fish.component(
            ofType: FishMovementComponent.self
        ) {
            movement.moveSpeed = 0
        }
        
        node.removeAllActions()
        node.zRotation = 0
        node.zPosition = 900
        
        let approachPoint = CGPoint(
            x: hookPosition.x + 42,
            y: hookPosition.y - 18
        )
        let circleLeft = CGPoint(
            x: hookPosition.x - 34,
            y: hookPosition.y - 24
        )
        let circleRight = CGPoint(
            x: hookPosition.x + 34,
            y: hookPosition.y - 18
        )
        
        let approachAction = SKAction.sequence([
            SKAction.run { [weak self, weak node] in
                guard let node else { return }
                self?.face(node, toward: approachPoint.x)
            },
            SKAction.move(
                to: approachPoint,
                duration: approachDuration
            )
        ])
        let hesitateAction = SKAction.sequence([
            SKAction.run { [weak self, weak node] in
                guard let node else { return }
                self?.face(node, toward: circleLeft.x)
            },
            SKAction.move(to: circleLeft, duration: hesitateDuration / 3),
            SKAction.run { [weak self, weak node] in
                guard let node else { return }
                self?.face(node, toward: circleRight.x)
            },
            SKAction.move(to: circleRight, duration: hesitateDuration / 3),
            SKAction.run { [weak self, weak node] in
                guard let node else { return }
                self?.face(node, toward: hookPosition.x)
            },
            SKAction.wait(forDuration: hesitateDuration / 3)
        ])
        
        node.run(
            SKAction.sequence([
                approachAction,
                hesitateAction,
                SKAction.run { [weak self] in
                    self?.resolveBite(
                        fish,
                        hookPosition: hookPosition,
                        currentTime: currentTime,
                        hookPower: hookPower,
                        onHooked: onHooked,
                        onFailed: onFailed
                    )
                }
            ]),
            withKey: "interestHook"
        )
    }
    
    private func resolveBite(
        _ fish: FishEntity,
        hookPosition: CGPoint,
        currentTime: TimeInterval,
        hookPower: CGFloat,
        onHooked: @escaping (FishEntity) -> Void,
        onFailed: @escaping (FishEntity) -> Void
    ) {
        let elapsedTime = currentTime - (sessionStartTime ?? currentTime)
        let shouldForceCatch = elapsedTime >= guaranteedCatchDelay
        let didBite = shouldForceCatch || TestCatchProbability.didCatch(
            fish: fish,
            boatPower: hookPower
        )
        
        if didBite {
            caughtFish = fish
            moveFishToHook(
                fish,
                hookPosition: hookPosition,
                onHooked: onHooked
            )
        } else {
            swimAway(
                fish,
                from: hookPosition,
                onFailed: onFailed
            )
        }
    }
    
    private func moveFishToHook(
        _ fish: FishEntity,
        hookPosition: CGPoint,
        onHooked: @escaping (FishEntity) -> Void
    ) {
        guard let node = fish.component(
            ofType: GKSKNodeComponent.self
        )?.node else {
            activeFish = nil
            return
        }
        
        face(node, toward: hookPosition.x)
        node.run(
            SKAction.sequence([
                SKAction.move(
                    to: hookPosition,
                    duration: 0.25
                ),
                SKAction.run {
                    onHooked(fish)
                }
            ]),
            withKey: "biteHook"
        )
    }
    
    private func swimAway(
        _ fish: FishEntity,
        from hookPosition: CGPoint,
        onFailed: @escaping (FishEntity) -> Void
    ) {
        guard let node = fish.component(
            ofType: GKSKNodeComponent.self
        )?.node else {
            activeFish = nil
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
                SKAction.move(
                    to: awayPoint,
                    duration: 0.6
                ),
                SKAction.run { [weak self] in
                    self?.restoreSwimming(for: fish)
                    self?.activeFish = nil
                    onFailed(fish)
                }
            ]),
            withKey: "failHook"
        )
    }
    
    private func restoreSwimming(for fish: FishEntity) {
        guard let movement = fish.component(
            ofType: FishMovementComponent.self
        ) else {
            return
        }
        
        movement.moveSpeed = 180 / max(movement.weight, 1)
        movement.direction = CGVector(
            dx: Bool.random() ? 1 : -1,
            dy: CGFloat.random(in: movement.verticalDriftRange)
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
    
    private func distanceSquared(
        from fish: FishEntity,
        to position: CGPoint
    ) -> CGFloat {
        guard let node = fish.component(ofType: GKSKNodeComponent.self)?.node else {
            return .greatestFiniteMagnitude
        }
        
        let dx = node.position.x - position.x
        let dy = node.position.y - position.y
        return dx * dx + dy * dy
    }
}
