//
//  FishMovementComponent.swift
//  Hook
//
//  Created by Christianto Elvern Haryanto on 12/05/26.
//

import GameplayKit

public class FishMovementComponent: GKComponent {
    var velocity: CGVector = .zero // CGVector is used to tell how fast and what direction it's going
    var direction: CGVector = CGVector(dx: 1, dy: 1) // Define fish's current horizontal & vertical movement direction
    var weight: CGFloat = 1 // Heavier fish move slower
    var moveSpeed: CGFloat = 100 // Fish's movement speed
    
    var verticalDriftRange: ClosedRange<CGFloat> = -0.3...0.3
    
    var directionChangeChance: Int = 100
    var yRange: ClosedRange<CGFloat> = -1800...0 // Keeps fish inside its assigned sea layer
    var layer: FishGenerator.SeaLayer = .epipelagic
    var isHooked: Bool = false
}
