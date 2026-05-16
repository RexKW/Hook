//
//  HookEntity.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//

import GameplayKit

class HookEntity: GKEntity {
    var stateMachine: GKStateMachine?
    
    init(node: SKNode, camera: SKCameraNode) {
        super.init()
        
        let nodeComponent = GKSKNodeComponent(node: node)
        addComponent(nodeComponent)
        
        let cameraComponent = CameraComponent(camera: camera)
        cameraComponent.target = node
        
        addComponent(StateComponent())
        addComponent(GameStateSystem())
        addComponent(InputComponent())
        addComponent(MovementComponent())
        addComponent(MovementSystem())
        addComponent(CameraSystem())
        addComponent(cameraComponent)
        
        stateMachine?.enter(IdleState.self)
    }
    required init?(coder: NSCoder) { fatalError() }
}

