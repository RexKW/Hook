//
//  CameraSystem.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//

import GameplayKit

class CameraSystem: GKComponentSystem<CameraComponent> {
    
    override func update(deltaTime seconds: TimeInterval) {
        for component in components {
           
            guard let entity = component.entity,
                  let node = entity.component(ofType: GKSKNodeComponent.self)?.node else { continue }
            
            let targetY = node.position.y
            component.cameraNode.position.y = min(0, targetY)
        }
    }
}
