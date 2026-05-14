//
//  WaitingState.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//

import GameplayKit

class WaitingState: GKState {
    weak var entity: HookEntity?
    
    init(entity: HookEntity) {
        self.entity = entity
        super.init()
    }
   
    override func didEnter(from previousState: GKState?) {
        entity?.component(ofType: StateComponent.self)?.currentState = .waiting
    }
}

