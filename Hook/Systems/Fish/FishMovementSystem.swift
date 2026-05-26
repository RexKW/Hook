//
//  FishMovementSystem.swift
//  Hook
//
//  Created by Christianto Elvern Haryanto on 12/05/26.
//

import GameplayKit

class FishMovementSystem: GKComponent {
    override func update(deltaTime seconds: TimeInterval) {
        guard let node = entity?.component(ofType: GKSKNodeComponent.self)?.node,
              let moveData = entity?.component(ofType: FishMovementComponent.self),
              let state = entity?.component(ofType: FishStateComponent.self)
        else { return }

        // Normal ECS movement only runs while the fish is swimming.
        guard state.stateMachine.currentState is SwimFishState,
              moveData.isHooked == false else {
            return
        }

        // Randomly change direction using layer-specific movement behavior.
        if Int.random(in: 0...moveData.directionChangeChance) == 0 {
            let horizontalDirection: CGFloat = moveData.direction.dx >= 0 ? 1 : -1
            
            moveData.direction = CGVector(
                dx: horizontalDirection,
                dy: CGFloat.random(in: moveData.verticalDriftRange)
            )
        }
        
        // Calculate the velocity
        moveData.velocity.dx = moveData.direction.dx * moveData.moveSpeed
        moveData.velocity.dy = moveData.direction.dy * moveData.moveSpeed
        
        // Applying the movement
        node.position = CGPoint(
            x: node.position.x + moveData.velocity.dx * CGFloat(seconds),
            y: node.position.y + moveData.velocity.dy * CGFloat(seconds)
        )

        if node.position.y < moveData.yRange.lowerBound {
            node.position.y = moveData.yRange.lowerBound
            moveData.direction.dy = abs(moveData.direction.dy)
        } else if node.position.y > moveData.yRange.upperBound {
            node.position.y = moveData.yRange.upperBound
            moveData.direction.dy = -abs(moveData.direction.dy)
        }
        
        // Remove fish if it goes off screen horizontally.
        let minX: CGFloat = -800
        let maxX: CGFloat = 800

        if node.position.x < minX || node.position.x > maxX {
            node.removeFromParent()
            entity?.removeComponent(ofType: FishMovementComponent.self)
        }
        
        // Handle facing direction
        if moveData.direction.dx > 0 {
            node.xScale = -abs(node.xScale)
        } else if moveData.direction.dx < 0 {
            node.xScale = abs(node.xScale)
        }
        
        // --- 🐟 NEW TILTING LOGIC 🐟 ---
        
        // 1. Define the maximum tilt angle in radians (15 degrees looks natural)
        let maxTilt: CGFloat = 15.0 * (.pi / 180.0)
        
        // 2. Calculate how fast it's moving vertically compared to its speed
        // This gives us a normalized value roughly between -1.0 and 1.0
        let verticalRatio = moveData.velocity.dy / max(moveData.moveSpeed, 1.0)
        
        // 3. Set the base rotation target
        var targetRotation = verticalRatio * maxTilt
        
        // 4. Invert rotation if facing left, so the "nose" always points in the direction of the movement
        if moveData.direction.dx < 0 {
            targetRotation = -targetRotation
        }
        
        // 5. Smoothly interpolate the current rotation to the target rotation
        let tiltSmoothness: CGFloat = 3.0
        node.zRotation += (targetRotation - node.zRotation) * CGFloat(seconds) * tiltSmoothness
    }
}
