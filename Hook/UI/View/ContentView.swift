//
//  ContentView.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 14/05/26.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    @State var isGameTime: Bool = false
    @State private var isUpgradeMenuPresented: Bool = false
    @State private var currentBoatLevel: Int = 1
    @State private var playerProgress: CGFloat = 0.0
    @State private var caughtFish: Fish? = nil
    
    var scene: SKScene {
        guard let scene = GameScene(fileNamed: "GameScene") else {
                    return SKScene()
                }
        scene.scaleMode = .aspectFill
        
        return scene ?? SKScene()
    }
    
    
    var body: some View {
        ZStack {
            
            SpriteView(scene: scene)
                .edgesIgnoringSafeArea(.all)
                .navigationBarBackButtonHidden(true)
            
            VStack(alignment: .center){
                if(!isGameTime){
                    TopBarView(isUpgradeMenuPresented: $isUpgradeMenuPresented, currentBoatLevel: $currentBoatLevel, playerProgress: $playerProgress)
                    Spacer()
                }
            }.padding()
            if isUpgradeMenuPresented {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation { isUpgradeMenuPresented = false }
                    }
                
                UpgradePopUpView(isUpgradeMenuPresented: $isUpgradeMenuPresented, currentBoatLevel: $currentBoatLevel)
            }
            
        }
        
    }
}

#Preview {
    ContentView()
}
