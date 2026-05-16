//
//  CastingState.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//

import GameplayKit

class CastingState: GKState {
    unowned let statusComp: StateComponent
    
    init(component: StateComponent) {
        self.statusComp = component
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {

        guard let entity = statusComp.entity,
              let node = entity.component(ofType: GKSKNodeComponent.self)?.node else {
            print("❌ CastingState: GKSKNodeComponent tidak ketemu")
            return
        }
        
//        entity.component(ofType: StateComponent.self)?.currentState = .casting
        
        node.run(SKAction.moveTo(y: -50, duration: 0.5)) { [weak self] in
            print("✅ Masuk ke Waiting State")
            self?.stateMachine?.enter(WaitingState.self)
        }
    }
}

