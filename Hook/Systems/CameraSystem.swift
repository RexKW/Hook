//
//  CameraSystem.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//

import GameplayKit
import SpriteKit

class CameraSystem: GKComponent {
    override func update(deltaTime seconds: TimeInterval) {
        guard let data = entity?.component(ofType: CameraComponent.self),
              let target = data.target
        else { return }
        
        let dx = target.position.x - data.cameraNode.position.x
        let dy = target.position.y - data.cameraNode.position.y
        
        data.cameraNode.position.x += dx * data.lerpFactor
        data.cameraNode.position.y += dy * data.lerpFactor
    }
}
