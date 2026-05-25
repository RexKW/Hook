//
//  HookTests.swift
//  HookTests
//
//  Created by Christianto Elvern Haryanto on 22/05/26.
//

import GameplayKit
import SpriteKit
import Testing
@testable import Hook

struct HookTests {

    //MARK: Fishing chance unit testing
    @MainActor
    @Test func isFishingChanceReturnValid() throws {
        let testWeights: [CGFloat] = [0.1, 1.0, 5.0, 50.0, 500.0]

        for weight in testWeights {
            let fish = FishEntity(node: SKSpriteNode())
            fish.component(ofType: FishMovementComponent.self)?.weight = weight

            let chance = TestCatchProbability.chanceToCatch(fish: fish, boatPower: 5)

            #expect(chance >= TestCatchProbability.minimumChance)
            #expect(chance <= TestCatchProbability.maximumChance)
            #expect(chance.isFinite)
        }
    }

}
