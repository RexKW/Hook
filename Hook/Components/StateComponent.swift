//
//  StateComponent.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//

import GameplayKit

class StateComponent: GKComponent {
    var currentState: HookState = .idle
    
    var boatTier: BoatTier = .boatLevel1
}

// Hook status
enum HookState {
    case idle, casting, waiting, reeling
}

// Zone limits according to ship level
enum BoatTier: CGFloat {
    case boatLevel1 = -200
    case boatLevel2 = -1000
    case boatLevel3 = -4000
}

