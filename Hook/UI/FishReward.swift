import SwiftUI

// MARK: - Color System
extension Color {
    // These strings MUST match the names of the Color Sets in your Assets folder
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
    static func gameOverlay(size: CGFloat = 18) -> Font {
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
    
    // Sample data for your game
    static let sampleData: [Fish] = [
        Fish(name: "Ruby snapper", imageName: "RubySnapperColor", weightKg: 1.2, imageHeight: 150),
        Fish(name: "Blue Marlin", imageName: "BlueMarlinFishColor", weightKg: 8.5, imageHeight: 200)
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
                            .font(.gameTitle(size: 32))
                            .foregroundColor(.DarkBrown)
                            .padding(.top, 24)
                        
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
        } // The correct closing brace for the Main ZStack is here
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

#Preview("2. Popup View Only") {
    // We pass a dummy fish just so the preview has data to render on the canvas
    FishCatchPopupView(fish: Fish.sampleData[0]) {
        print("Dismissed!")
    }
}
