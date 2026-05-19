import SwiftUI

// MARK: - Color System
extension Color {
    // These strings MUST match the names of the Color Sets in your Assets folder
    static let DarkBrown = Color("Color5")
    static let White  = Color("Color2")
}
// MARK: - Typography System
extension Font {
    // 1. Title Font Variation
    static func gameTitle(size: CGFloat = 32) -> Font {
        return .custom("RawPixel-Bold", size: size)
    }
    
    // 2. Body Font Variation
    static func gameBody(size: CGFloat = 24) -> Font {
        // Replace "YourBodyFont-Regular" with your actual font file's PostScript name
        return .custom("loficoregular", size: size)
    
    }
    // 3. Overlay Font Variation
    static func gameOverlay(size: CGFloat = 18) -> Font {
        return .custom("loficoregular", size: size)
    }
}

// MARK: - 2. Data Model
struct Fish: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
    let weightKg: Double

    var formattedWeight: String {
        let formatted = String(format: "%.1f", weightKg).replacingOccurrences(of: ".", with: ",")
        return "\(formatted) kg"
    }
    
    // Sample data for your game
    static let sampleData: [Fish] = [
        Fish(name: "Ruby snapper", imageName: "ruby_snapper", weightKg: 1.2),
        Fish(name: "Blue Marlin", imageName: "blue_marlin", weightKg: 8.5)
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

// MARK : -4. Popup View
struct FishCatchPopupView: View {
    let fish: Fish
    let onDismiss: () -> Void

    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Background Dim
            Color.black.opacity(0.2)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            VStack(spacing: 24) {
                ZStack {
                    // BACKGROUND CONTAINER ASSET
                    Image("polaroid")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300)
                    
                    // FOREGROUND DATA
                    VStack(spacing: 0) {
                        
                        // TITLE TEXT
                        Text(fish.name)
                            .font(.gameTitle(size: 24)) // Clean Title Call
                            .foregroundColor(.DarkBrown) // Clean Color Call
                            .padding(.top, 24)
                        
                        Spacer()
                        
                        // FISH ASSET
                        Image(fish.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 90)
                            .offset(y: isAnimating ? 0 : 15)
                        
                        Spacer()
                        
                        // WEIGHT TEXT
                        Text(fish.formattedWeight)
                            .font(.gameBody(size: 20)) // Clean Body Call
                            .foregroundColor(.white)
                            .padding(.bottom, 24)
                    }
                    .frame(width: 280, height: 320)
                }
                
                // DISMISS TEXT
                Text("Tap to dismiss")
                    .font(.gameBody(size: 22)) // Clean Body Call
                    .foregroundColor(Color.white)// Clean Color Call
            }
        }
        .opacity(isAnimating ? 1 : 0)
        .scaleEffect(isAnimating ? 1 : 0.8)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isAnimating = true
            }
        }
        .onTapGesture { dismiss() }
    }

    private func dismiss() {
        withAnimation(.easeIn(duration: 0.15)) {
            isAnimating = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            onDismiss()
        }
    }
}
// MARK: - 5. Previews
// These allow you to view the screens directly in the Xcode Canvas

#Preview("1. Full Game Screen") {
    GameView()
}

#Preview("2. Popup View Only") {
    // We pass a dummy fish just so the preview has something to render
    FishCatchPopupView(fish: Fish.sampleData[0]) {
        print("Dismissed!")
    }
}
