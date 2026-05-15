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
        
        addComponent(StateComponent())
        addComponent(InputComponent())
        addComponent(MovementComponent())
        addComponent(CameraComponent(camera: camera))
        
        stateMachine = GKStateMachine(states: [
            IdleState(entity: self),
            CastingState(entity: self),
            WaitingState(entity: self),
            ReelingState(entity: self)
        ])
        stateMachine?.enter(IdleState.self)
    }
    required init?(coder: NSCoder) { fatalError() }
}

