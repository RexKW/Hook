//
//  GameStateSystem.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//

import GameplayKit

class GameStateSystem: GKComponent {
    override func update(deltaTime seconds: TimeInterval) {
        guard let status = entity?.component(ofType: StateComponent.self)
        else{ return }
        
        status.stateMachine.update(deltaTime: seconds)
    }
}
