//
//  ContentView.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 14/05/26.
//

import SwiftUI
import SpriteKit
import SwiftData

struct ContentView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var isUpgradeMenuPresented: Bool = false
    @State private var isFishCollectionPresented: Bool = false
    @State private var gameScene: GameScene?
    @State private var isFading = false
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                if let scene = gameScene {
                    SpriteView(scene: scene)
                        .edgesIgnoringSafeArea(.all)
                        .navigationBarBackButtonHidden(true)
                }
                
                VStack(alignment: .center){
                    
                    if(!viewModel.isGameTime){
                        ZStack{
                            VStack(alignment: .center){
                                TopBarView(
                                    isUpgradeMenuPresented: $isUpgradeMenuPresented,
                                    isFishCollectionPresented: $isFishCollectionPresented,
                                    currentBoatLevel: $viewModel.currentBoatLevel,
                                    playerProgress: $viewModel.playerProgress
                                )
                                Spacer()
                            }
                            
                            VStack{
                                Text("Hold to Lower")
                                    .font(.custom("RawPixel-Bold", size: 32))
                                
                                Text("Hook")
                                    .font(.custom("RawPixel-Bold", size: 96))
                                    .foregroundColor(Color(red: 0.016, green: 0.345, blue: 0.631))
                                    .opacity(isFading ? 0.4 : 1.0)
                                    .onAppear {
                                        withAnimation(
                                            .easeInOut(duration: 1.0)
                                            .repeatForever(autoreverses: true)
                                        ) {
                                            isFading.toggle()
                                        }
                                    }
                                
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .offset(y: -75)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        
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
                
                if isFishCollectionPresented{
                    Color.black.opacity(0.6)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation { isFishCollectionPresented = false }
                        }
                    
                    CollectionPopUpView(isPresent: $isFishCollectionPresented)
                }
                
                
                if let fish = viewModel.caughtFish {
                    RewardPopUpView(fish: fish) {
                        viewModel.gainExperience()
                        // This clears the fish data, which hides the popup
                        viewModel.caughtFish = nil
                    }
                    .zIndex(1) // Ensures the popup is always on top
                }
                
                
                
            }
            .onAppear {
                isFading = true
                
                viewModel.configurePersistence(modelContext: modelContext)
                
                if let scene = GameScene(fileNamed: "GameScene") {
                    scene.scaleMode = .aspectFill
                    scene.gameVM = viewModel // Inject the ViewModel here
                    scene.modelContext = modelContext
                    self.gameScene = scene   // Save it to state
                }
            }
        }
        
        
    }
}

#Preview {
    ContentView()
        .environmentObject(GameViewModel())
        .modelContainer(for: [FishModel.self, PlayerProgressModel.self], inMemory: true)
}
