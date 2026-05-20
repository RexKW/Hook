//
//  HookEntity.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//

import GameplayKit
import SpriteKit

class HookEntity: GKEntity {
    var stateMachine: GKStateMachine?
    
    // Perbarui parameter init agar menerima SKShapeNode dan SKLabelNode dari GameScene
    init(node: SKNode, camera: SKCameraNode, bg: SKSpriteNode, pointer: SKSpriteNode, icon: SKSpriteNode, lockOverlay: SKShapeNode, lockLabel: SKLabelNode) {
        super.init()
        
        let nodeComponent = GKSKNodeComponent(node: node)
        addComponent(nodeComponent)
        
        let cameraComponent = CameraComponent(camera: camera)
        cameraComponent.target = node
        
        let indicatorComponent = ProgressionIndicatorComponent(
            bg: bg,
            pointer: pointer,
            icon: icon,
            lockOverlay: lockOverlay,
            lockLabel: lockLabel
        )
        
        addComponent(StateComponent())
        addComponent(GameStateSystem())
        addComponent(InputComponent())
        addComponent(MovementComponent())
        addComponent(MovementSystem())
        addComponent(CameraSystem())
        addComponent(cameraComponent)
        addComponent(indicatorComponent)
        
        stateMachine?.enter(IdleState.self)
    }
    required init?(coder: NSCoder) { fatalError() }
}
