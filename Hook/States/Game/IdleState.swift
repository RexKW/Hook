//
//  IdleState.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//

import GameplayKit

class IdleState: GKState {
    unowned let statusComp: StateComponent
    
    init(component: StateComponent) {
            self.statusComp = component
            super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
//        entity?.component(ofType: StateComponent.self)?.currentState = .idle
        print("Hook Ready!")
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return  stateClass is CastingState.Type
    }
}
