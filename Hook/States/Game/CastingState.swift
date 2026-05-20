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
            print("🎣 Casting State: Hook is ready to drop!")

    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return  stateClass is WaitingState.Type
    }
}

