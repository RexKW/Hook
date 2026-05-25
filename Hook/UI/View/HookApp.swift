//
//  HookApp.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 20/05/26.
//

import SwiftUI
import SwiftData


struct HookApp: App {
    @StateObject private var gameViewModel = GameViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(onDismiss: {})
                .environmentObject(gameViewModel)
        }
        .modelContainer(for: [FishModel.self, PlayerProgressModel.self])
    }
}
