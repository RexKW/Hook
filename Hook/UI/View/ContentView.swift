//
//  ContentView.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 14/05/26.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @State private var isUpgradeMenuPresented: Bool = false
    @State private var gameScene: GameScene?
    
    
    var body: some View {
        ZStack {
            
            if let scene = gameScene {
                SpriteView(scene: scene)
                    .edgesIgnoringSafeArea(.all)
                    .navigationBarBackButtonHidden(true)
            }
            
            VStack(alignment: .center){
                if(!viewModel.isGameTime){
                    TopBarView(isUpgradeMenuPresented: $isUpgradeMenuPresented, currentBoatLevel: $viewModel.currentBoatLevel, playerProgress: $viewModel.playerProgress)
                    Spacer()
                }
            }.padding()
            if isUpgradeMenuPresented {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation { isUpgradeMenuPresented = false }
                    }
                
                UpgradePopUpView(isUpgradeMenuPresented: $isUpgradeMenuPresented, currentBoatLevel: $viewModel.currentBoatLevel)
            }
            
            
            if let fish = viewModel.caughtFish {
                RewardPopUpView(fish: fish) {
                    // This clears the fish data, which hides the popup
                    viewModel.caughtFish = nil
                }
                .zIndex(1) // Ensures the popup is always on top
            }
            
            
            
        }
        .onAppear {
            if let scene = GameScene(fileNamed: "GameScene") {
                scene.scaleMode = .aspectFill
                scene.gameVM = viewModel // Inject the ViewModel here
                self.gameScene = scene   // Save it to state
            }
        }
        
    }
}

#Preview {
    ContentView()
        .environmentObject(GameViewModel())
}
