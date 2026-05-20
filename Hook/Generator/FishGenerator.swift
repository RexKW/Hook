//
//  FishGenerator.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//

import SpriteKit
import GameplayKit

class FishGenerator {

    enum SeaLayer {
        case epipelagic
        case mesopelagic
        case bathypelagic
    }
    
    private struct FishSpawnData {
        let textureName: String
        let weightRange: ClosedRange<CGFloat>
    }

    static func spawnFish(
        in scene: SKScene,
        fishEntities: inout [FishEntity],
        layer: SeaLayer
    ) {

        // MARK: - Sea Boundaries

        let seaTop: CGFloat = 0
        let layerHeight = scene.size.height * 2.5
        let epipelagicBottom = seaTop - layerHeight
        let mesopelagicBottom = epipelagicBottom - layerHeight
        let bathypelagicBottom = mesopelagicBottom - layerHeight

        // MARK: - Fish Data

        let fishOptions: [FishSpawnData]
        let yRange: ClosedRange<CGFloat>
        let verticalDriftRange: ClosedRange<CGFloat>
        let directionChangeChance: Int

        switch layer {

        case .epipelagic:

            fishOptions = [
                FishSpawnData(textureName: "Tuna fish", weightRange: 1...35),
                FishSpawnData(textureName: "Mackerel", weightRange: 2...50),
                FishSpawnData(textureName: "lionfish-export", weightRange: 0.2...1.2)
            ]

            yRange = epipelagicBottom...seaTop
            verticalDriftRange = -0.6...0.6
            directionChangeChance = 70

        case .mesopelagic:

            fishOptions = [
                FishSpawnData(textureName: "Ruby snapper", weightRange: 15...200),
                FishSpawnData(textureName: "Hatchet Fish", weightRange: 5...60),
                FishSpawnData(textureName: "OarFish", weightRange: 10...400),
                FishSpawnData(textureName: "Bluenose warehou Fish", weightRange: 30...300)
            ]

            yRange = mesopelagicBottom...epipelagicBottom
            verticalDriftRange = -0.3...0.3
            directionChangeChance = 120

        case .bathypelagic:

            fishOptions = [
                FishSpawnData(textureName: "anglerfish-new", weightRange: 50...800),
                FishSpawnData(textureName: "Ratail fish", weightRange: 35...500),
                FishSpawnData(textureName: "fangtooth1-export", weightRange: 40...700),
                FishSpawnData(textureName: "Giant Squid", weightRange: 68...907),
            ]

            yRange = bathypelagicBottom...mesopelagicBottom
            verticalDriftRange = -0.12...0.12
            directionChangeChance = 180
        }
        
        guard let selectedFish = fishOptions.randomElement() else {
            return
        }
        
        let fishTexture = SKTexture(
            imageNamed: selectedFish.textureName
        )

        // MARK: - Create Fish Node

        let fishNode = SKSpriteNode(
            texture: fishTexture
        )

        // MARK: - Spawn Direction

        let spawnFromLeft = Bool.random()

        let spawnX: CGFloat =
            spawnFromLeft ? -450 : 450

        fishNode.position = CGPoint(
            x: spawnX,
            y: CGFloat.random(in: yRange)
        )

        // Flip sprite depending on direction
        fishNode.xScale = spawnFromLeft ? 1 : -1

        // MARK: - Create Entity

        let fish = FishEntity(node: fishNode)

        // MARK: - Movement Configuration

        if let moveData = fish.component(
            ofType: FishMovementComponent.self
        ) {

            let horizontalDirection: CGFloat =
                spawnFromLeft ? 1 : -1

            moveData.direction = CGVector(
                dx: horizontalDirection,
                dy: CGFloat.random(in: verticalDriftRange)
            )

            moveData.weight = CGFloat.random(in: selectedFish.weightRange)
            moveData.moveSpeed = 180 / moveData.weight
            moveData.verticalDriftRange = verticalDriftRange
            moveData.directionChangeChance = directionChangeChance
            moveData.yRange = yRange
            moveData.layer = layer
        }

        // MARK: - Store Entity

        fishEntities.append(fish)

        // MARK: - Add To Scene

        scene.addChild(fishNode)
    }
}
