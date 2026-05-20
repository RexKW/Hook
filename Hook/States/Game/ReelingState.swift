//
//  ReelingState.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//

import GameplayKit

class ReelingState: GKState {
    unowned let statusComp: StateComponent
    
    init(component: StateComponent) {
        self.statusComp = component
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        print("entered Reeling State")
        //        entity?.component(ofType: StateComponent.self)?.currentState = .reeling
        //    }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return  stateClass is IdleState.Type
    }
}

