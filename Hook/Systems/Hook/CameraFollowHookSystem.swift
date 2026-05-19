//
//  CameraFollowHookSystem.swift
//  Hook
//
//  Created by OpenAI on 13/05/26.
//

import GameplayKit
import SpriteKit

class CameraFollowHookSystem {
    private(set) var hookEntity: HookEntity?
    private var topOffsetY: CGFloat = 0
    private let centerOffsetY: CGFloat = 0
    private let hookCenteringSpeed: CGFloat = 260
    private weak var attachedFishNode: SKNode?
    
    func attachHook(
        entity: HookEntity,
        viewportHeight: CGFloat
    ) {
        self.hookEntity = entity
        self.topOffsetY = viewportHeight * 0.28
//        camera.addChild(hookNode)
    }
    
    func update() {
//        guard let hookNode = hookEntity?.component(ofType: GKSKNodeComponent.self)?.node else {
//            return
//        }
//        
//        hookNode.position.x = 0
    }
    
    func baitPosition(in scene: SKScene) -> CGPoint? {
        guard let hookNode = hookEntity?.component(ofType: GKSKNodeComponent.self)?.node else {
            return nil
        }
        
        let baitLocalPosition = CGPoint(x: 0, y: -46)
        return hookNode.convert(baitLocalPosition, to: scene)
    }
    
    func moveTowardCenter(deltaTime: TimeInterval) {
        guard let hookNode = hookEntity?.component(ofType: GKSKNodeComponent.self)?.node else {
            return
        }
        
        let nextY = hookNode.position.y - hookCenteringSpeed * CGFloat(deltaTime)
        hookNode.position.y = max(nextY, centerOffsetY)
    }
    
    func attachCaughtFish(
        _ fish: FishEntity,
        in scene: SKScene
    ) {
        guard
            let hookNode = hookEntity?.component(ofType: GKSKNodeComponent.self)?.node,
            let fishNode = fish.component(ofType: GKSKNodeComponent.self)?.node
        else {
            return
        }
        print("hook scale:", hookNode.xScale, hookNode.yScale, "fish scale:", fishNode.xScale, fishNode.yScale)
        
        let fishScenePosition = fishNode.convert(CGPoint.zero, to: scene)
        fishNode.removeAllActions()
        fishNode.removeFromParent()
        fishNode.position = hookNode.convert(fishScenePosition, from: scene)
        fishNode.zRotation = fishNode.xScale >= 0 ? 0.35 : -0.35
        fishNode.zPosition = 1001
        hookNode.addChild(fishNode)
        attachedFishNode = fishNode
        
        // To make sure the fish doesn't get scaled down
        do {
            let hookScaleX = hookNode.xScale
            let hookScaleY = hookNode.yScale
            let sign: CGFloat = fishNode.xScale >= 0 ? 1.0 : -1.0
            let safeX = max(abs(hookScaleX), 0.0001)
            let safeY = max(abs(hookScaleY), 0.0001)
            fishNode.xScale = sign * (1.0 / safeX)
            fishNode.yScale = 1.0 / safeY
        }
        
        let attachedOffsetX: CGFloat = fishNode.xScale >= 0 ? -40 : 40
        fishNode.run(
            SKAction.move(
                to: CGPoint(x: attachedOffsetX, y: -70),
                duration: 0.12
            )
        )
    }
    
    func removeAttachedFish() {
        attachedFishNode?.removeFromParent()
        attachedFishNode = nil
    }
    
    func resetToTop() {
        guard let hookNode = hookEntity?.component(ofType: GKSKNodeComponent.self)?.node else {
            return
        }
        
        hookNode.removeAction(forKey: "resetToTop")
        hookNode.run(
            SKAction.moveTo(y: topOffsetY, duration: 0.35),
            withKey: "resetToTop"
        )
    }
    
    func playTapAnimation() {
        guard let hookNode = hookEntity?.component(ofType: GKSKNodeComponent.self)?.node else {
            return
        }
        
        hookNode.removeAction(forKey: "tapAnimation")
        hookNode.run(
            SKAction.sequence([
                SKAction.group([
                    SKAction.scale(to: 1.25, duration: 0.12),
                    SKAction.rotate(byAngle: 0.2, duration: 0.12)
                ]),
                SKAction.group([
                    SKAction.scale(to: 1.0, duration: 0.12),
                    SKAction.rotate(toAngle: 0, duration: 0.12)
                ])
            ]),
            withKey: "tapAnimation"
        )
    }
}
