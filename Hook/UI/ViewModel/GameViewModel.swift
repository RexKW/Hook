//
//  GameViewModel.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 20/05/26.
//

import Foundation
import Combine
import SwiftUI

class GameViewModel: NSObject, ObservableObject {
    @Published var currentBoatLevel: Int = 1
    @Published var playerProgress: CGFloat = 0.0
    @Published var caughtFish:  FishModel? = nil
    @Published var isGameTime: Bool = false
    
    
    
    func gainExperience() {
        withAnimation(.easeInOut) {
            playerProgress += 0.5
            if playerProgress >= 1.0 {
                playerProgress = 0.0
                if currentBoatLevel < 3 {
                    currentBoatLevel += 1
                }
            }
        }
    }
    
}
