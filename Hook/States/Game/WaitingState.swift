//
//  WaitingState.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//

import GameplayKit

class WaitingState: GKState {
    unowned let statusComp: StateComponent
    
    init(component: StateComponent) {
        self.statusComp = component
        super.init()
    }
   
    override func didEnter(from previousState: GKState?) {
//        entity?.component(ofType: StateComponent.self)?.currentState = .waiting
    }
    
    
}

