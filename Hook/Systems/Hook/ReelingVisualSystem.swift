//
//  ReelingVisualSystem.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 13/05/26.
//

//
//  SkillCheckSystem.swift
//  CircularPullFishing
//

import GameplayKit

class ReelingVisualSystem: GKComponent {
    override func update(deltaTime seconds: TimeInterval) {
        // Fetch the required components from the entity
        guard let visuals = entity?.component(ofType: ReelingVisualComponent.self),
              let logic = entity?.component(ofType: ReelingComponent.self)
        else { return }
        
        // Update wheel rotation
        visuals.indicatorNode.zRotation = logic.currentAngle
        visuals.drawTargetZone(startAngle: logic.targetStartAngle, width: logic.targetWidth)
        
    }
}
