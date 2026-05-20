
//
//  IdleState.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//

import GameplayKit

class   CancelState: GKState {
    unowned let statusComp: StateComponent
    
    init(component: StateComponent) {
        self.statusComp = component
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        print("Cancelled State")
        //        entity?.component(ofType: StateComponent.self)?.currentState = .reeling
        //    }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return  stateClass is IdleState.Type
    }
    
    
}
