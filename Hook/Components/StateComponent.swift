//
//  StateComponent.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//

import GameplayKit
import SpriteKit

class StateComponent: GKComponent {
    var stateMachine: GKStateMachine
    
    var hookPosition: CGPoint?
    var hookPower: CGFloat = 5
    var sessionStartTime: TimeInterval?
    var guaranteedCatchDelay: TimeInterval = 14.5
    var approachDuration: TimeInterval = 1.1
    var hesitateDuration: TimeInterval = 1.0
    var onHooked: ((FishEntity) -> Void)?
    var onFailed: ((FishEntity) -> Void)?
    
    override init() {
        self.stateMachine = GKStateMachine(states: [])
        
        super.init()
        
        let states = [
            SwimFishState(component: self),
            InterestedFishState(component: self),
            NibbleFishState(component: self),
            HookedFishState(component: self)
        ]
        
        self.stateMachine = GKStateMachine(states: states)
        self.stateMachine.enter(SwimFishState.self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
