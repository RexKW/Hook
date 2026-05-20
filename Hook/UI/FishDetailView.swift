//
//  FishDetailView.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//

import SwiftUI

struct FishDetailView: View {
    @Environment(\.dismiss) private var dismiss

    let fish: FishDetailState

    init(fish: FishDetailState = FishDatabase.all[0]) {
        self.fish = fish
    }

    static let containerImageAsset = "ContainerFishAlbum"

    var body: some View {
        GeometryReader { proxy in
            let cardWidth = min(proxy.size.width * 0.88, 380)
            let cardHeight = cardWidth * (560.0 / 360.0)

            ZStack {
                Color.blue.opacity(0.4).ignoresSafeArea()

                ZStack(alignment: .topLeading) {
                    Image(Self.containerImageAsset)
                        .resizable()
                        .scaledToFit()

                    VStack(spacing: 14) {
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

                        Image(fish.imageName)
                            .resizable()
                            .interpolation(.none)
                            .aspectRatio(contentMode: .fit)
                            .frame(height: cardHeight * 0.26)
                            .padding(.top, 6)

                        Rectangle()
                            .fill(Color.DarkBrown.opacity(0.7))
                            .frame(height: 2)
                            .padding(.horizontal, 8)

                        Text(fish.name)
                            .font(.custom("RawPixel-Bold", size: 26))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.DarkBrown)
                            )

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

                        Rectangle()
                            .fill(Color.DarkBrown.opacity(0.4))
                            .frame(height: 1)
                            .padding(.horizontal, 8)
                            .padding(.top, 2)

                        Text(fish.description)
                            .font(.custom("RawPixel-Bold", size: 20))
                            .foregroundColor(.DarkBrown)
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                            .padding(.horizontal, 4)

                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, cardWidth * 0.10)
                    .padding(.top, cardHeight * 0.04)
                    .padding(.bottom, cardHeight * 0.06)
                    .frame(width: cardWidth, height: cardHeight)

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
