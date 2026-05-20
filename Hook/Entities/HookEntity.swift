//
//  HookEntity.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//

import GameplayKit

class HookEntity: GKEntity {
    var stateMachine: GKStateMachine?
    
    init(node: SKNode, camera: SKCameraNode, bg: SKSpriteNode, pointer: SKSpriteNode, icon: SKSpriteNode) {
        super.init()
        
        let nodeComponent = GKSKNodeComponent(node: node)
        addComponent(nodeComponent)
        
        let cameraComponent = CameraComponent(camera: camera)
        cameraComponent.target = node
        
        // komponen logic dengan referensi node dari scene
        let indicatorComponent = ProgressionIndicatorComponent(bg: bg, pointer: pointer, icon: icon)
        
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

