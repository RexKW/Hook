//
//  SwimFishState.swift
//  Hook
//
//  Created by Christianto Elvern Haryanto on 12/05/26.
//

import GameplayKit

class SwimFishState: GKState {
    unowned let stateComp: FishStateComponent
    
    init(component: FishStateComponent){
        self.stateComp = component
        super.init()
    }
    
    // To initiate what states could the current state acccess
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == InterestedFishState.self ||
        stateClass == NibbleFishState.self ||
        stateClass == HookedFishState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        guard let movement = stateComp.entity?.component(ofType: FishMovementComponent.self) else {
            return
        }
        
        movement.isHooked = false
        movement.moveSpeed = CGFloat.random(in: 50...100)
    }
    
    override func update(deltaTime seconds: TimeInterval){
        
    }
}
