//
//  TestCatchProbability.swift
//  Hook
//
//  Created by OpenAI on 13/05/26.
//

import GameplayKit
import SpriteKit

struct TestCatchProbability {
    static let minimumChance: CGFloat = 0.1
    static let maximumChance: CGFloat = 0.9
    
    static func chanceToCatch(
        fish: FishEntity,
        boatPower: CGFloat = 5
    ) -> CGFloat {
        guard let movementComponent = fish.component(
            ofType: FishMovementComponent.self
        ) else {
            return 0
        }
        
        let weight = max(movementComponent.weight, 1)
        let rawChance = boatPower / (boatPower + weight)
        
        return min(
            max(rawChance, minimumChance),
            maximumChance
        )
    }
    
    static func didCatch(
        fish: FishEntity,
        boatPower: CGFloat = 5,
        roll: CGFloat = CGFloat.random(in: 0...1)
    ) -> Bool {
        roll <= chanceToCatch(
            fish: fish,
            boatPower: boatPower
        )
    }
}
