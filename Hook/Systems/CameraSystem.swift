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
        
        data.cameraNode.position.y = target.position.y + 650
    }
}
