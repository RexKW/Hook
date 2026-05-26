//
//  ReelingComponent.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 12/05/26.
//

import GameplayKit

class ReelingComponent: GKComponent {
    var currentAngle: CGFloat = 0.0
    var rotationSpeed: CGFloat = 3.0
    
    var targetStartAngle: CGFloat = 0.0
    let targetWidth: CGFloat
    
    var catchProgress: CGFloat = 0.0 // Ranges from 0.0 (escaped) to 1.0 (caught)
    let progressPerSuccess: CGFloat = 0.2 // Takes 5 perfect hits to catch
    let penaltyPerMiss: CGFloat = 0.1 // Lose progress if you miss
    
    init(targetWidthRadians: CGFloat = .pi / 2) {
        self.targetWidth = targetWidthRadians
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
