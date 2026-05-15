//
//  TestGameScene.swift
//  Hook
//
//  Created by Christianto Elvern Haryanto on 12/05/26.
//

import SpriteKit
import GameplayKit

class TestGameScene: SKScene {
    
    var fishEntities: [FishEntity] = []
    var fishMovementSystem = GKComponentSystem(componentClass: FishMovementSystem.self)
    
    private let seaLayers: [FishGenerator.SeaLayer] = [
        .epipelagic,
        .mesopelagic,
        .bathypelagic
    ]
    private let fishCountPerLayer = 5
    
    override func didMove(to view: SKView) {
        spawnFishInAllLayers()
    }
    
    override func update(_ currentTime: TimeInterval) {
        let deltaTime: TimeInterval = 1.0 / 60.0
        fishMovementSystem.update(deltaTime: deltaTime)

        // Remove invalid fish entities
        fishEntities.removeAll {
            $0.component(ofType: GKSKNodeComponent.self)?.node.parent == nil
        }

        // Keep fish visible across all layers
        while fishEntities.count < fishCountPerLayer * seaLayers.count {
            for layer in seaLayers where fishEntities.count < fishCountPerLayer * seaLayers.count {
                spawnFish(layer: layer)
            }
        }
    }
    
    private func spawnFishInAllLayers() {
        for layer in seaLayers {
            for _ in 0..<fishCountPerLayer {
                spawnFish(layer: layer)
            }
        }
    }
    
    private func spawnFish(layer: FishGenerator.SeaLayer) {
        FishGenerator.spawnFish(
            in: self,
            fishEntities: &fishEntities,
            layer: layer
        )

        if let movementComponent = fishEntities.last?.component(
            ofType: FishMovementSystem.self
        ) {
            fishMovementSystem.addComponent(
                movementComponent
            )
        }
    }
}
