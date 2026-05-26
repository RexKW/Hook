//
//  RewardPopUpView.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 21/05/26.
//

import SwiftUI

struct RewardPopUpView: View {
    let fish: FishModel
    let onDismiss: () -> Void
    
    
    
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background Overlay
            Color.black.opacity(0.2)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }
            
            VStack(spacing: 24) {
                
                // POLAROID CARD CONTAINER
                ZStack {
                    // LAYER 1: BACKGROUND ASSET
                    Image("polaroid")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300)
                    
                    // LAYER 2: FISH IMAGE
                    Image(fish.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: fish.imageHeight)
                        .offset(y: isAnimating ? 0 : 15)
                    
                    // LAYER 3: TEXT DATA
                    VStack(spacing: 0) {
                        
                        Text(fish.name)
                            .font(.gameTitle(size: 28))
                            .font(.custom("RawPixel-Bold", size: 28))
                            .foregroundColor(.DarkBrown)
                            .padding(.top, 32)
                        
                        Spacer()
                        Text(fish.formattedWeight)
                            .font(.gameBody(size: 20))
                            .foregroundColor(.white)
                            .padding(.bottom, 24)
                    }
                    .frame(width: 280, height: 320)
                }
                .onTapGesture { dismiss() }
                
                Text("Tap to dismiss")
                    .font(.gameBody(size: 22))
                    .foregroundColor(Color.white)
            }
        }
        .opacity(isAnimating ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isAnimating = true
            }
        }
    }
    
    private func dismiss() {
        withAnimation(.easeOut(duration: 0.20)) {
            isAnimating = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
            onDismiss()
        }
    }
}


#Preview {
    let fishModels = [
        FishModel(imageName: "Tuna Fish", weightKg: 12.5),
        FishModel(imageName: "Mackerel", weightKg: 8.0),
        FishModel(imageName: "Lion Fish", weightKg: 150.0),
        FishModel(imageName: "Marlin", weightKg: 95.0),
        FishModel(imageName: "Ruby Snapper", weightKg: 12.5),
        FishModel(imageName: "Hatchet Fish", weightKg: 3.2),
        FishModel(imageName: "Oar Fish", weightKg: 40.0),
        FishModel(imageName: "Bluenose warehou Fish", weightKg: 18.5),
        FishModel(imageName: "anglerfish-new1", weightKg: 6.8),
        FishModel(imageName: "Ratail fish", weightKg: 2.4),
        FishModel(imageName: "fangtooth1-export 1", weightKg: 5.5),
        FishModel(imageName: "Giant Squid", weightKg: 275.0)
    ]

    ScrollView {
        LazyVStack {
            ForEach(fishModels, id: \.id) { fish in
                RewardPopUpView(fish: fish, onDismiss: {})
            }
        }
    }
}
