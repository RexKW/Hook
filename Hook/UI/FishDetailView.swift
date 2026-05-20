//
//  FishDetailView.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//

import SwiftUI

struct FishDetail {
    let imageName: String
    let name: String
    let bestWeight: String      // e.g. "20 Kg"
    let timesCaught: Int        // e.g. 12
    let description: String
}

struct FishDetailView: View {
    @Environment(\.dismiss) private var dismiss

    let fish: FishDetail

    // Default sample so previews / existing call sites still compile
    init(fish: FishDetail = FishDetail(
        imageName: "RubySnapperColor",
        name: "Ruby Snapper",
        bestWeight: "20 Kg",
        timesCaught: 12,
        description: "Ps= I'm not staring, my eyes are just built like this because the water pressure is too real, fr fr!"
    )) {
        self.fish = fish
    }

    static let containerImageAsset = "ContainerFishAlbum"

    var body: some View {
        GeometryReader { proxy in
            // Scale the whole card to the available width, keeping the art ratio.
            let cardWidth = min(proxy.size.width * 0.88, 380)
            let cardHeight = cardWidth * (560.0 / 360.0)   // match your container art ratio

            ZStack {
                Color.blue.opacity(0.4).ignoresSafeArea()

                ZStack(alignment: .topLeading) {

                    // 1. Background container art
                    Image(Self.containerImageAsset)
                        .resizable()
                        .scaledToFit()

                    // 2. Card content
                    VStack(spacing: 14) {

                        // Title with pink underline
                        Text("FISH LOG")
                            .font(.custom("RawPixel-Bold", size: 32))
                            .foregroundColor(.DarkBrown)
                            .overlay(alignment: .bottom) {
                                Rectangle()
                                    .fill(Color.pink)
                                    .frame(height: 3)
                                    .offset(y: 6)
                            }
                            .padding(.top, 30)

                        // Fish image
                        Image(fish.imageName)
                            .resizable()
                            .interpolation(.none)
                            .aspectRatio(contentMode: .fit)
                            .frame(height: cardHeight * 0.26)
                            .padding(.top, 6)

                        // Divider line
                        Rectangle()
                            .fill(Color.DarkBrown.opacity(0.7))
                            .frame(height: 2)
                            .padding(.horizontal, 8)

                        // Name plate
                        Text(fish.name)
                            .font(.custom("RawPixel-Bold", size: 26))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.DarkBrown)
                            )

                        // Stat pills row
                        HStack(spacing: 12) {
                            statPill {
                                Image(systemName: "trophy.fill")
                                    .foregroundColor(.white)
                                Text(fish.bestWeight)
                                    .font(.custom("RawPixel-Bold", size: 20))
                                    .foregroundColor(.white)
                            }
                            statPill {
                                Image(systemName: "diamond.fill")
                                    .foregroundColor(.white)
                                Text("\(fish.timesCaught) Caught")
                                    .font(.custom("RawPixel-Bold", size: 20))
                                    .foregroundColor(.white)
                            }
                        }

                        // Thin divider above description
                        Rectangle()
                            .fill(Color.DarkBrown.opacity(0.4))
                            .frame(height: 1)
                            .padding(.horizontal, 8)
                            .padding(.top, 2)

                        // Description text
                        Text(fish.description)
                            .font(.custom("RawPixel-Bold", size: 20))
                            .foregroundColor(.DarkBrown)
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                            .padding(.horizontal, 4)

                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, cardWidth * 0.10)   // inset from wooden border
                    .padding(.top, cardHeight * 0.04)
                    .padding(.bottom, cardHeight * 0.06)
                    .frame(width: cardWidth, height: cardHeight)

                    // 3. Back button — top-left, overlapping the corner
                    Button(action: { dismiss() }) {
                        Image("ButtonBack")
                            .resizable()
                            .frame(width: 52, height: 52)
                    }
                    .offset(x: -6, y: 4)
                }
                .frame(width: cardWidth, height: cardHeight)
            }
        }
    }

    // MARK: - Reusable stat pill
    @ViewBuilder
    private func statPill<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 8) {
            content()
        }
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
    FishDetailView()
}
