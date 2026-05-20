//
//  ContentView.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 14/05/26.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
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
            
        }
        
    }
}

#Preview {
    ContentView()
}
