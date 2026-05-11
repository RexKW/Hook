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
    
    init(camera: SKCameraNode) {
        self.cameraNode = camera
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
