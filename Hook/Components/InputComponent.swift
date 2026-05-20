//
//  InputComponent.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//

import GameplayKit

class InputComponent: GKComponent {
    var isHolding = false
    var isTapped = false
    
    func handleTouchBegan() {
        isHolding = true
        isTapped = true
    }
    
    func handleTouchEnded() {
        isHolding = false
    }
}
