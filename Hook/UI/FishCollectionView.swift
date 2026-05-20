//
//  FishCollection.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//

import SwiftUI

struct FishCollectionView: View {
    @Environment(\.dismiss) private var dismiss

    static let backgroundImageAsset = "ContainerFishAlbum"
    static let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    // Tune these to match your asset's painted frame
    private let containerWidth: CGFloat = 360
    private let containerHeight: CGFloat = 560

    // Holds the tapped fish; non-nil value drives the sheet.
    @State private var selectedFish: FishDetailState?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.blue.opacity(0.4).ignoresSafeArea()

                // Container art defines the frame; everything layers on top.
                ZStack(alignment: .topTrailing) {

                    // 1. Background paper/frame art
                    Image(Self.backgroundImageAsset)
                        .resizable()
                        .scaledToFit()

                    // 2. Content INSIDE the container (title + scrolling grid)
                    VStack(spacing: 12) {
                        Text("FISH ALBUM")
                            .font(.custom("RawPixel-Bold", size: 32))
                            .foregroundColor(.DarkBrown)
                            .padding(.top, 36)
                            .offset(x: -20, y: -20)

                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVGrid(columns: Self.columns, spacing: 12) {
                                ForEach(FishDatabase.all) { fish in
                                    fishCell(for: fish)
                                }
                            }
                            .padding(.horizontal, 6)
                            .padding(.top, 4)
                            .padding(.bottom, 24)
                        }
                        .clipped()   // keep scrolling fish from bleeding over the frame
                    }
                    // Inset content so it sits within the painted frame.
                    .padding(.horizontal, 34)
                    .padding(.top, 18)
                    .padding(.bottom, 40)

                    // 3. Exit button overlapping the top-right corner
                    Button(action: { dismiss() }) {
                        Image("ButtonExit")
                            .resizable()
                            .frame(width: 58, height: 60)
                    }
                    .offset(x: 2, y: -1)
                }
                .frame(width: containerWidth, height: containerHeight)
            }
            // Item-based sheet: presents whenever selectedFish becomes non-nil.
            .sheet(item: $selectedFish) { fish in
                FishDetailView(fish: fish)
            }
        }
    }

    // MARK: - Single fish frame
    @ViewBuilder
    private func fishCell(for fish: FishDetailState) -> some View {
        Button(action: { selectedFish = fish }) {
            ZStack {
                Image("BorderIcon")
                    .resizable()
                    .interpolation(.none)
                    .aspectRatio(1, contentMode: .fit)

                GeometryReader { geo in
                    Image(fish.isUnlocked ? fish.imageName : fish.silhouetteName)
                        .resizable()
                        .interpolation(.none)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geo.size.width * 0.55, height: geo.size.height * 0.55)
                        .frame(width: geo.size.width, height: geo.size.height)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    FishCollectionView()
}
