//
//  ReelMechanicComponent.swift
//  CircularPullFishing
//
//  Created by Rex Kenny Wirasantoso on 10/05/26.
//

import GameplayKit

class ReelingSystem: GKComponent {
//    var currentAngle: CGFloat = 0.0
//    var rotationSpeed: CGFloat = 3.0
//    
//    var targetStartAngle: CGFloat = 0.0
//    let targetWidth: CGFloat
//    
//    var catchProgress: CGFloat = 0.0 // Ranges from 0.0 (escaped) to 1.0 (caught)
//    let progressPerSuccess: CGFloat = 0.2 // Takes 5 perfect hits to catch
//    let penaltyPerMiss: CGFloat = 0.1 // Lose progress if you miss
    
//    init(targetWidthRadians: CGFloat = .pi / 4) {
//        self.targetWidth = targetWidthRadians
//        super.init()
//        randomizeTarget()
//    }
//     
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
    override func update(deltaTime seconds: TimeInterval) {
            guard let reelData = entity?.component(ofType: ReelingComponent.self)
            else { return }
            
            super.update(deltaTime: seconds)
            reelData.currentAngle += reelData.rotationSpeed * CGFloat(seconds)
            reelData.currentAngle = reelData.currentAngle.truncatingRemainder(dividingBy: 2 * .pi)
        
        
    }
    
    func randomizeTarget() {
        guard let reelData = entity?.component(ofType: ReelingComponent.self)
              
        else { return }
        reelData.targetStartAngle = CGFloat.random(in: 0..<(2 * .pi))
    }
    
    func attemptReel() -> Bool {
        guard let reelData = entity?.component(ofType: ReelingComponent.self),
              let reelVisual = entity?.component(ofType: ReelingVisualComponent.self)
        else { return false }
        let targetEndAngle = reelData.targetStartAngle + reelData.targetWidth
        let success: Bool
        
        if targetEndAngle > 2 * .pi {
            let wrappedEnd = targetEndAngle - (2 * .pi)
            success = reelData.currentAngle >= reelData.targetStartAngle || reelData.currentAngle <= wrappedEnd
        } else {
            success = reelData.currentAngle >= reelData.targetStartAngle && reelData.currentAngle <= targetEndAngle
        }
        
        if success {
            reelData.catchProgress = min(1.0, reelData.catchProgress + reelData.progressPerSuccess)
        } else {
            reelData.catchProgress = max(0.0, reelData.catchProgress - reelData.penaltyPerMiss)
            reelVisual.triggerFailureEffect()
        }
        
        return success
    }
}
