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

    // Holds the tapped fish; non-nil value shows the detail view.
    @State private var selectedFish: FishDetailState?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.blue.opacity(0.4).ignoresSafeArea()

                // --- ALBUM (fades out when a fish is selected) ---
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
                            .offset(x: -20, y: -8)

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
                    .padding(.top, 8)
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
                .opacity(selectedFish == nil ? 1 : 0)   // fade album out on select

                // --- DETAIL (fades in over the same space, transparent backdrop) ---
                if let fish = selectedFish {
                    FishDetailView(fish: fish) {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            selectedFish = nil           // Back clears selection
                        }
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.25), value: selectedFish?.id)
        }
    }

    // MARK: - Single fish frame
    @ViewBuilder
    private func fishCell(for fish: FishDetailState) -> some View {
        Button(action: {
            if fish.isUnlocked {
                withAnimation(.easeInOut(duration: 0.25)) {
                    selectedFish = fish
                }
            }
        }) {
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
        .disabled(!fish.isUnlocked)   // locked fish can't be tapped
    }
}

#Preview {
    FishCollectionView()
}
