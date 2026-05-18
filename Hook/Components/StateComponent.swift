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
    var approachDuration: TimeInterval = TimeInterval(Int.random(in: 1...5))
    var hesitateDuration: TimeInterval = TimeInterval(Int.random(in: 1...10))
    var onHooked: ((FishEntity) -> Void)?
    var onFailed: ((FishEntity) -> Void)?
    var ignoreHookUntilTime: TimeInterval = 0
    
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
