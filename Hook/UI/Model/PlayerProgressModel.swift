//
//  PlayerProgressModel.swift
//  Hook
//
//  Created by OpenAI on 21/05/26.
//

import Foundation
import SwiftData

@Model
class PlayerProgressModel {
    var currentBoatLevel: Int
    var playerProgress: Double

    init(currentBoatLevel: Int = 1, playerProgress: Double = 0.0) {
        self.currentBoatLevel = currentBoatLevel
        self.playerProgress = playerProgress
    }
}
