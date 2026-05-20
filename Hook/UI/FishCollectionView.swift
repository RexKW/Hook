//
//  FishCollection.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//

import SwiftUI

struct FishEntry: Identifiable {
    let id = UUID()
    let name: String
    let colorImageName: String
    let silhouetteImageName: String
    var isUnlocked: Bool
}

struct FishCollectionView: View {
    @Environment(\.dismiss) private var dismiss
    
    static let fishAlbum: [FishEntry] = [
        FishEntry(name: "Tuna", colorImageName: "TunaFishColor", silhouetteImageName: "TunaFish", isUnlocked: true),
        FishEntry(name: "Mackerel", colorImageName: "MackerelFishColor", silhouetteImageName: "MackerelFish", isUnlocked: true),
        FishEntry(name: "Lionfish", colorImageName: "LionFishColor", silhouetteImageName: "LionFish", isUnlocked: false),
        FishEntry(name: "AnglerFish", colorImageName: "AnglerFishColor", silhouetteImageName: "AnglerFish", isUnlocked: false),
        FishEntry(name: "Ratail", colorImageName: "RatailFishColor", silhouetteImageName: "RatailFish", isUnlocked: false),
        FishEntry(name: "Snapper", colorImageName: "RubySnapperColor", silhouetteImageName: "RubySnapper", isUnlocked: false),
        FishEntry(name: "Oarfish", colorImageName: "OarFishColor", silhouetteImageName: "OarFish", isUnlocked: false),
        FishEntry(name: "BlueNose", colorImageName: "BlueNoseWarehouColor", silhouetteImageName: "BluenoseWarehouFish", isUnlocked: false),
        FishEntry(name: "Marlin", colorImageName: "BlueMarlinFishColor", silhouetteImageName: "MarlinFish", isUnlocked: false),
        FishEntry(name: "HatchetFish", colorImageName: "HatchetFishColor", silhouetteImageName: "HatchetFish", isUnlocked: false),
        FishEntry(name: "Fangtooth", colorImageName: "FangToothColor", silhouetteImageName: "FangToothFish", isUnlocked: false),
        FishEntry(name: "GiantSquid", colorImageName: "GiantSquidColor", silhouetteImageName: "GiantSquid", isUnlocked: false)
    ]
    
    static let backgroundImageAsset = "ContainerFishAlbum"
    static let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    // Tune these to match your asset's painted frame
    private let containerWidth: CGFloat = 360
    private let containerHeight: CGFloat = 560
    
    @State private var showDetail = false
    
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
                                ForEach(Self.fishAlbum) { fish in
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
            .sheet(isPresented: $showDetail) {
                FishDetailView()
            }
        }
    }
    
    // MARK: - Single fish frame
    @ViewBuilder
    private func fishCell(for fish: FishEntry) -> some View {
        Button(action: { showDetail = true }) {
            ZStack {
                // The border tile defines the cell, square
                Image("BorderIcon")
                    .resizable()
                    .interpolation(.none)
                    .aspectRatio(1, contentMode: .fit)
                
                // The fish is hard-bounded to ~55% of the tile so tall
                // shapes (squid) and wide shapes (tuna) both stay inside.
                GeometryReader { geo in
                    Image(fish.isUnlocked ? fish.colorImageName : fish.silhouetteImageName)
                        .resizable()
                        .interpolation(.none)
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            width: geo.size.width * 0.55,
                            height: geo.size.height * 0.55
                        )
                        .frame(width: geo.size.width, height: geo.size.height) // center it
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    FishCollectionView()
}
