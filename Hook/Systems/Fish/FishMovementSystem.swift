//
//  FishMovementSystem.swift
//  Hook
//
//  Created by Christianto Elvern Haryanto on 12/05/26.
//

import GameplayKit

class FishMovementSystem: GKComponent{
    override func update(deltaTime seconds: TimeInterval){
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
        let minX: CGFloat = -500
        let maxX: CGFloat = 500

        if node.position.x < minX ||
            node.position.x > maxX {
            node.removeFromParent()
            entity?.removeComponent(ofType: FishMovementComponent.self)
        }
        
        // Handle facing direction
        if moveData.direction.dx > 0 {
            node.xScale = -abs(node.xScale)
        }else if moveData.direction.dx < 0{
            node.xScale = abs(node.xScale)
        }
    }
}
