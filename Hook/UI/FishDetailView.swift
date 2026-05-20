//
//  FishDetail.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//

import SwiftUI

struct FishDetailView: View {
    // Fish detail card for displaying information about a single fish
    static var backgroundImageAsset = "ContainerFishDetail"
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        // Entire screen background layer
        ZStack {
            // Set white background to fill the device screen
            Color.blue.opacity(0.4).ignoresSafeArea()
            
            // Vertically center the fish detail card
            VStack {
                // Push card to vertical center
                Spacer()
                
                // Card container with decorative image and overlayed content
                ZStack(alignment: .topLeading) {
                    // Card background image asset
                    Image("ContainerDetailFish")
                        .resizable()
                        .frame(width: 400, height: 600)
                        .aspectRatio(contentMode: .fit)
                    
                    Button(action: { dismiss() }) {
                        Image("Button-Back")
                            .resizable()
                            .frame(width: 55, height: 55)
                    }
                    .padding(.top, 46)
                    .padding(.leading, 21)
                    
                    // Stack all card content vertically
                    VStack(spacing: 0) {
                        // Title section: FISH LOG
                        Text("FISH LOG")
                            .font(.system(size: 28, weight: .heavy, design: .monospaced))
                            .foregroundColor(.brown)
                            .frame(height: 80)
                            .padding(.top, 80)
                        
                        // Fish sprite image
                        Image("")
                            .resizable()
                            .interpolation(.none)
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 110)
                            .padding(.vertical, 8)
                        
                        // Fish name label in colored capsule
                        Text("Ruby Snapper")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color(red: 164/255, green: 63/255, blue: 55/255)))
                            .padding(.top, 2)
                        
                        // Info row: trophy and diamond icons with text
                        HStack(spacing: 28) {
                            HStack(spacing: 6) {
                                Image(systemName: "trophy.fill")
                                    .foregroundColor(.yellow)
                                Text("20 Kg")
                                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                                    .foregroundColor(.brown)
                            }
                            HStack(spacing: 6) {
                                Image(systemName: "diamond.fill")
                                    .foregroundColor(.gray)
                                Text("12 Caught")
                                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                                    .foregroundColor(.brown)
                            }
                        }
                        .padding(.top, 8)
                        
                        // Description/caption text
                        Text("Ps- I'm not staring, my eyes are just built like this because the water pressure is too real, fr fr!")
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(Color(red: 92/255, green: 55/255, blue: 28/255))
                            .multilineTextAlignment(.center)
                            .padding(.top, 10)
                            .padding(.horizontal, 16)
                        
                        // Spacer: push content to top within card
                        Spacer()
                    }
                    // Constrain content width/height inside card
                    .frame(width: 290, height: 340)
                }
                
                // Push card to vertical center
                Spacer()
            }
        }
    }
}

#Preview {
    FishDetailView()
}
