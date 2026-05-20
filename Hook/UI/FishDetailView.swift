//
//  FishDetailView.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//

import SwiftUI

struct FishDetailView: View {
    let fish: FishDetailState
    var onBack: () -> Void
    
    init(fish: FishDetailState = FishDatabase.all[0], onBack: @escaping () -> Void = {}) {
        self.fish = fish
        self.onBack = onBack
    }
    
    static let containerImageAsset = "ContainerFishDetail"
    
    var body: some View {
        GeometryReader { proxy in
            let cardWidth = min(proxy.size.width * 0.88, 380)
            let cardHeight = cardWidth * (560.0 / 360.0)
            
            ZStack {
                // No background fill — fully transparent.
                ZStack(alignment: .topLeading) {
                    Image(Self.containerImageAsset)
                        .resizable()
                        .scaledToFit()
                    
                    VStack(spacing: 14) {
                        Text("FISH LOG")
                            .font(.custom("RawPixel-Bold", size: 32))
                            .foregroundColor(.DarkBrown)
                            .offset(x: 20, y: -15)
                            .padding(.top, 30)
                        
                        Image(fish.imageName)
                            .resizable()
                            .interpolation(.none)
                            .aspectRatio(contentMode: .fit)
                            .scaleEffect(fish.displayScale)
                            .frame(height: cardHeight * 0.26)
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .padding(.top, 6)
                        
                        Rectangle()
                            .fill(Color.DarkBrown)
                            .frame(height: 3)
                            .padding(.horizontal, 8)
                        
                        Text(fish.name)
                            .font(.custom("Loficore", size: 28))
                            .foregroundColor(.color2)
                            .frame(maxWidth: .infinity, maxHeight: 24)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.DarkBrown)
                            )
                        
                        HStack(spacing: 12) {
                            statPill {
                                Image("Trophy")
                                
                                    .resizable()
                                    .interpolation(.none)
                                    .scaledToFit()
                                    .frame(width: 22, height: 22)
                                
                                Text(fish.bestWeight)
                                    .font(.custom("RawPixel-Bold", size: 20))
                                    .foregroundColor(.color2)
                                
                            }
                            statPill {
                                Image(systemName: "diamond.fill")
                                    .foregroundColor(.color2)
                                Text("\(fish.timesCaught) Caught")
                                    .font(.custom("RawPixel-Bold", size: 20))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                                    .foregroundColor(.color2)
                            }
                        }
                        Rectangle()
                            .fill(Color.DarkBrown)
                            .frame(height: 3)
                            .padding(.horizontal, 8)
                        
                        Text(fish.description)
                            .font(.custom("Loficore", size: 18))
                            .foregroundColor(.DarkBrown)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(3)
                            .frame(maxWidth: .infinity)
                        
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, cardWidth * 0.10)
                    .padding(.top, cardHeight * 0.04)
                    .padding(.bottom, cardHeight * 0.06)
                    .frame(width: cardWidth, height: cardHeight)
                    
                    Button(action: { onBack() }) {
                        Image("ButtonBack")
                            .resizable()
                            .frame(width: 58, height: 58)
                    }
                    .offset(x: 0, y: 0)
                }
                .frame(width: cardWidth, height: cardHeight)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
    }
    
    @ViewBuilder
    private func statPill<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 8) { content() }
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.DarkBrown)
            )
    }
}

#Preview {
    FishDetailView(fish: FishDatabase.all[0])
}
