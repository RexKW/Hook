//
//  FishStateSystem.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//

import GameplayKit

class FishStateSystem: GKComponent {
    override func update(deltaTime seconds: TimeInterval) {
        
        // Declare / update each fishes' state
        entity?
            .component(ofType: FishStateComponent.self)?
            .stateMachine
            .update(deltaTime: seconds)
    }
}
