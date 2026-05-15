//
//  FishStateSystem.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//

import GameplayKit

class FishStateSystem: GKComponent {
    override func update(deltaTime seconds: TimeInterval) {
        entity?
            .component(ofType: StateComponent.self)?
            .stateMachine
            .update(deltaTime: seconds)
    }
}
