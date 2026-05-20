//
//  StateComponent.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//

import GameplayKit

class StateComponent: GKComponent {
    var stateMachine: GKStateMachine!
    var boatTier: BoatTier = .boatLevel1
    
    override init() {
            super.init()
            
        let states = [
            IdleState(component: self),
            CastingState(component: self),
            WaitingState(component: self),
            ReelingState(component: self),
            CancelState(component: self)
        ]
            
        self.stateMachine = GKStateMachine(states: states)
        self.stateMachine.enter(IdleState.self)
        
        
    }
    
    required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
    }
}

// Zone limits according to ship level
enum BoatTier: CGFloat {
    case boatLevel1 = -6150
    case boatLevel2 = -10000
    case boatLevel3 = -15800
}

