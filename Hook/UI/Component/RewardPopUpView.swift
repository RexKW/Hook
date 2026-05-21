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


