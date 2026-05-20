import SwiftUI

// MARK: - Data Model & UI (View)
struct BoatGameView: View {
    @State private var isUpgradeMenuPresented: Bool = false
    @State private var currentBoatLevel: Int = 1
    @State private var playerProgress: CGFloat = 0.0 // Dimulai dari 0%
    
    var body: some View {
        ZStack {
            Color.blue.opacity(0.4).ignoresSafeArea()
            
            VStack {
                topBarUI
                
                Spacer()
                
                Button(action: {
                    gainExperience()
                }) {
                    Text("Simulasi Main (Tambah XP)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                }
                
                Spacer()
            }
            .padding()
            
            // Overlay & Pop-up
            if isUpgradeMenuPresented {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation { isUpgradeMenuPresented = false }
                    }
                
                upgradePopupMenu
            }
        }
    }
    
    // MARK: - UI COMPONENTS
    private var topBarUI: some View {
        HStack {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isUpgradeMenuPresented.toggle()
                }
            }) {
                HStack(spacing: 0) {
                    Text("\(currentBoatLevel)")
                        .font(.system(size: 24, weight: .bold))
                        .frame(width: 50, height: 50)
                        .background(Color.brown.opacity(0.8))
                        .foregroundColor(.white)
                        .border(Color.black, width: 2)
                    
                    // --- PROGRESS BAR ---
                    ZStack(alignment: .leading) {
                        Rectangle().fill(Color.darkcream)
                            .frame(width: 100, height: 25)
                        
                        Rectangle().fill(Color.blue)
                            .frame(width: 100 * playerProgress, height: 25)
                            .animation(.easeInOut, value: playerProgress)
                        
                        Text("\(Int(playerProgress * 100))%")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.white)
                            .padding(.leading, 30)
                    }
                    .border(Color.DarkBrown, width: 2)
                }
            }
            Spacer()
            
            // --- BOOK BUTTON ASSET ---
            Button(action: {}) {
                Image("ButtonBook")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
            }
            .padding(12)
            
        }
    }
    
    private var upgradePopupMenu: some View {
        ZStack(alignment: .topTrailing) {
            
            // --- CUSTOM CONTAINER (Popup Content) ---
            VStack(spacing: 25) {
                
                // --- EXPLICIT ASSET SWAPPING FOR EACH LEVEL ---
                boatUpgradeRow(level: 1,
                               colorAsset: "Boat 1_Icon",
                               silhouetteAsset: nil)
                
                boatUpgradeRow(level: 2,
                               colorAsset: "Boat 2_Icon",
                               silhouetteAsset: "boat_2_Lock")
                
                boatUpgradeRow(level: 3,
                               colorAsset: "Boat 3_Icon",
                               silhouetteAsset: "boat_3_Lock")
            }
            
            .padding(.horizontal, 50)
            .padding(.vertical, 60)
            
            .background(
                Image("ContainerBoat")
                    .resizable()
                    .scaledToFill()
            )
            
            // --- CLOSE BUTTON ASSET ---
            Button(action: {
                withAnimation { isUpgradeMenuPresented = false }
            }) {
                Image("ButtonExit")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
            }
            
            .offset(x: 76, y: 45)
        }
    }
    // MARK: - COMPONENT DEFINITIONS
    
    // Row Builder with Asset-Swapping Logic
    private func boatUpgradeRow(level: Int, colorAsset: String, silhouetteAsset: String?) -> some View {
        let isUnlocked = currentBoatLevel >= level
        
        // LOGIC: If unlocked, use colorAsset. If locked, use silhouetteAsset.
        // If silhouetteAsset is nil (like Level 1), fallback to colorAsset safely.
        let assetToShow = isUnlocked ? colorAsset : (silhouetteAsset ?? colorAsset)
        
        return VStack(spacing: 8) {
            
            // Render the specific asset file chosen by the logic above
            Image(assetToShow)
                .resizable()
                .scaledToFit()
                .frame(height: 120)
            
            Text("Level \(level)")
                .font(.system(size: 18, weight: .semibold, design: .monospaced))
                .foregroundColor(isUnlocked ? Color.DarkBrown : Color.gray)
        }
    }
    
    // MARK: - CORE GAME LOGIC
    private func gainExperience() {
        withAnimation(.easeInOut) {
            playerProgress += 0.5
            if playerProgress >= 1.0 {
                playerProgress = 0.0
                if currentBoatLevel < 3 {
                    currentBoatLevel += 1
                }
            }
        }
    }
}

#Preview {
    BoatGameView()
}
