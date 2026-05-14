//
//  CameraComponent.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//

import GameplayKit
import SpriteKit

class CameraComponent: GKComponent {
    let cameraNode: SKCameraNode
    var target: SKNode?
    var lerpFactor: CGFloat = 0.1

    init(camera: SKCameraNode) {
        self.cameraNode = camera
        super.init()
    }
    
    required init?(coder: NSCoder) {
        self.cameraNode = SKCameraNode()
        super.init()
    }
}
