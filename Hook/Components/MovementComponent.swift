//
//  MovementComponent.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//

import GameplayKit
import SpriteKit

class MovementComponent: GKComponent {
    // Data Kecepatan
    var speed: CGFloat = 7.0
    var returnSpeed: CGFloat = 15.0
    
    // Zone
    var surfaceY: CGFloat = 20
    var zone1Limit: CGFloat = -200
    var zone2Limit: CGFloat = -1000
    var zone3Limit: CGFloat = -4000
}
