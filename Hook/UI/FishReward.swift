import SwiftUI

// MARK: - Color System
extension Color {
    static let DarkBrown = Color("Color5")
    static let White  = Color("Color2")
}
// MARK: - Typeface System
extension Font {
    // 1. Title Font Variation
    static func gameTitle(size: CGFloat = 32) -> Font {
        return .custom("RawPixel-Bold", size: size)
    }
    
    // 2. Body Font Variation
    static func gameBody(size: CGFloat = 24) -> Font {
        return .custom("Loficore", size: size)
        
    }
    // 3. Overlay Font Variation
    static func gameOverlay(size: CGFloat = 22) -> Font {
        return .custom("Loficore", size: size)
    }
}

// MARK: - 2. Data Model
struct Fish: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
    let weightKg: Double
    let imageHeight: CGFloat?
    
    var formattedWeight: String {
        let formatted = String(format: "%.1f", weightKg).replacingOccurrences(of: ".", with: ",")
        return "\(formatted) kg"
    }
    
    // Sample data fish
    static let sampleData: [Fish] = [
        Fish(name: "Oar Fish", imageName: "OarFishColor", weightKg: 1.2, imageHeight: 110),
        Fish(name: "Ruby snapper", imageName: "RubySnapperColor", weightKg: 1.2, imageHeight: 150),
        Fish(name: "Marlin Fish", imageName: "BlueMarlinFishColor", weightKg: 7.5, imageHeight: 200),
        Fish(name: "Mackerel Fish", imageName: "MackerelFishColor", weightKg: 8.5, imageHeight: 170),
        Fish(name: "Giant Squid", imageName: "GiantSquidColor", weightKg: 2.5, imageHeight: 170),
        Fish(name: "Bluenose Warehou", imageName: "BlueNoseWarehouColor", weightKg: 10.5, imageHeight: 120),
        Fish(name: "Tuna Fish", imageName: "TunaFishColor", weightKg: 9.5, imageHeight: 320),
        Fish(name: "Lion Fish", imageName: "LionFishColor", weightKg: 8.5, imageHeight: 200),
        Fish(name: "FangTooth Fish", imageName: "FangToothColor", weightKg: 0.5, imageHeight: 200),
        Fish(name: "Angler Fish", imageName: "AnglerFishColor", weightKg: 6.5, imageHeight: 200),
        Fish(name: "Ratail Fish", imageName: "RatailFishColor", weightKg: 3.5, imageHeight: 160),
        Fish(name: "Hatchet Fish", imageName: "HatchetFishColor", weightKg: 1.5, imageHeight: 150),
    ]
}

// MARK: - 3. Game Screen (Main View) delete this if the pop up view is finish
struct GameView: View {
    @State private var caughtFish: Fish? = nil
    
    var body: some View {
        ZStack {
            // 1. Your Game Background
            // Replace this color with your actual background image: Image("game_background").resizable().ignoresSafeArea()
            Color(red: 0.56, green: 0.82, blue: 0.95)
                .ignoresSafeArea()
            
            // 2. A temporary button to test catching a fish
            VStack {
                Spacer()
                Button("🎣 Catch Fish") {
                    // Randomly pick a fish from your sample data
                    caughtFish = Fish.sampleData.randomElement()
                }
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
                .padding(.bottom, 50)
            }
            
            // 3. The Popup Layer (Shows up only when a fish is caught)
            if let fish = caughtFish {
                FishCatchPopupView(fish: fish) {
                    // This clears the fish data, which hides the popup
                    caughtFish = nil
                }
                .zIndex(1) // Ensures the popup is always on top
            }
        }
    }
}

// MARK: - 4. Popup View
struct FishCatchPopupView: View {
    let fish: Fish
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

// MARK: - 5. Previews

#Preview("1. Full Game Screen") {
    GameView()
}


#Preview("Oar Fish") {
    FishCatchPopupView(fish: Fish.sampleData[0]) {
        print("Oar Fish closed")
    }
}
#Preview("Ruby Snapper ") {
    FishCatchPopupView(fish: Fish.sampleData[1]) {
        print("Ruby Snapper closed")
    }
}

#Preview("Marlin Fish ") {
    FishCatchPopupView(fish: Fish.sampleData[2]) {
        print("Blue Marlin closed")
    }
}

#Preview("Mackerel Fish ") {
    FishCatchPopupView(fish: Fish.sampleData[3]) {
        print("Mackerel Fish closed")
    }
}

#Preview("Giant Squid") {
    FishCatchPopupView(fish: Fish.sampleData[4]) {
        print("Giant squid closed")
    }
}

#Preview("Bluenose Warehou") {
    FishCatchPopupView(fish: Fish.sampleData[5]) {
        print("bluenose warehou closed")
    }
}

#Preview("Tuna Fish") {
    FishCatchPopupView(fish: Fish.sampleData[6]) {
        print("tuna fish closed")
    }
}

#Preview("Lion Fish") {
    FishCatchPopupView(fish: Fish.sampleData[7]) {
        print("Lion fish closed")
    }
}

#Preview("FangTooth Fish") {
    FishCatchPopupView(fish: Fish.sampleData[8]) {
        print("FangTooth fish closed")
    }
}

#Preview("Angler Fish") {
    FishCatchPopupView(fish: Fish.sampleData[9]) {
        print("Anglerfish closed")
    }
}

#Preview("Ratail Fish") {
    FishCatchPopupView(fish: Fish.sampleData[10]) {
        print("Ratail Fish closed")
    }
}

#Preview("Hatchet Fish") {
    FishCatchPopupView(fish: Fish.sampleData[11]) {
        print("Hatchet Fish closed")
    }
}


