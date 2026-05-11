//
//  MovementComponent.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//

import GameplayKit
import SpriteKit

class MovementComponent: GKComponent {
    // Data/Atribut (Ini yang dipakai oleh State nanti)
    var speed: CGFloat = 7.0
    var returnSpeed: CGFloat = 15.0
    var bottomLimit: CGFloat = -3000
    var surfaceY: CGFloat = 20
    
}
