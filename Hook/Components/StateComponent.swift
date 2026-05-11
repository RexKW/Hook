//
//  StateComponent.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//

import GameplayKit

class StateComponent: GKComponent {
    var currentState: HookState = .idle
}

enum HookState {
    case idle, casting, waiting, reeling, captured
}
