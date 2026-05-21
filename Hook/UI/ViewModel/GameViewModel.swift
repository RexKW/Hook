//
//  GameViewModel.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 20/05/26.
//

import Foundation
import Combine
import SwiftUI
import SwiftData

class GameViewModel: NSObject, ObservableObject {
    @Published var currentBoatLevel: Int = 1 {
        didSet { savePlayerProgress() }
    }
    @Published var playerProgress: CGFloat = 0.0 {
        didSet { savePlayerProgress() }
    }
    @Published var caughtFish: FishModel? = nil
    @Published var isGameTime: Bool = false

    private var modelContext: ModelContext?
    private var playerProgressModel: PlayerProgressModel?
    private var isLoadingPlayerProgress = false

    func configurePersistence(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadPlayerProgress()
    }

    func gainExperience() {
        guard let caughtFish else { return }

        withAnimation(.easeInOut) {
            guard currentBoatLevel < maximumBoatLevel else {
                playerProgress = 1.0
                return
            }

            let requiredWeight = requiredWeightForNextLevel()
            let gainedProgress = caughtFish.weightKg / requiredWeight
            playerProgress = min(playerProgress + gainedProgress, 1.0)

            if playerProgress >= 1.0 {
                playerProgress = 0.0
                currentBoatLevel += 1
            }
        }
    }

    private var maximumBoatLevel: Int {
        3
    }

    private func requiredWeightForNextLevel() -> CGFloat {
        switch currentBoatLevel {
        case 1:
            return 120.0
        case 2:
            return 1_200.0
        default:
            return .greatestFiniteMagnitude
        }
    }

    private func loadPlayerProgress() {
        guard let modelContext else { return }

        do {
            let descriptor = FetchDescriptor<PlayerProgressModel>()
            if let storedProgress = try modelContext.fetch(descriptor).first {
                isLoadingPlayerProgress = true
                playerProgressModel = storedProgress
                currentBoatLevel = storedProgress.currentBoatLevel
                playerProgress = CGFloat(storedProgress.playerProgress)
                isLoadingPlayerProgress = false
            } else {
                let newProgress = PlayerProgressModel(
                    currentBoatLevel: currentBoatLevel,
                    playerProgress: Double(playerProgress)
                )
                modelContext.insert(newProgress)
                playerProgressModel = newProgress
                try modelContext.save()
            }
        } catch {
            print("Failed to load player progress: \(error.localizedDescription)")
            isLoadingPlayerProgress = false
        }
    }

    private func savePlayerProgress() {
        guard !isLoadingPlayerProgress, let modelContext else { return }

        let progressModel: PlayerProgressModel
        if let playerProgressModel {
            progressModel = playerProgressModel
        } else {
            progressModel = PlayerProgressModel()
            modelContext.insert(progressModel)
            playerProgressModel = progressModel
        }

        progressModel.currentBoatLevel = currentBoatLevel
        progressModel.playerProgress = Double(playerProgress)

        do {
            try modelContext.save()
        } catch {
            print("Failed to save player progress: \(error.localizedDescription)")
        }
    }
}
