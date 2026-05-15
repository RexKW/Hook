//
//  ContentView.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 14/05/26.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    let scene: SKScene = SKScene(fileNamed: "GameScene")!
    
    var body: some View {
        VStack{
            SpriteView(scene: scene).ignoresSafeArea()
        }.padding(0).frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
}
