import SwiftUI

struct BoatGameView: View {
    // MARK: - Parameters & Logic State
    // @State bertindak sebagai "memori" dari layar ini. Jika nilainya berubah, desain otomatis menyesuaikan.
    @State private var isUpgradeMenuPresented: Bool = false
    @State private var currentBoatLevel: Int = 1
    @State private var playerProgress: CGFloat = 0.5 // 50% progress
    
    var body: some View {
        ZStack {
            // 1. BACKGROUND LAYER
            Color.blue.opacity(0.4) // Ganti dengan Image("background_ocean") milik Anda
                .edgesIgnoringSafeArea(.all)
            
            // 2. MAIN UI LAYER
            VStack {
                topBarUI
                Spacer()
                // Tempat perahu utama berlayar di layar utama (bisa ditambahkan nanti)
            }
            .padding()
            
            // 3. OVERLAY & POP-UP LAYER
            if isUpgradeMenuPresented {
                // Dimmed Overlay
                Color.black.opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        // Menutup pop-up jika area gelap disentuh
                        isUpgradeMenuPresented = false
                    }
                
                // Pop-up Menu
                upgradePopupMenu
            }
        }
    }
    
    // MARK: - Functions / Logic
    // Fungsi ini dipanggil ketika player memenuhi syarat untuk naik level
    func unlockNewBoatLevel(newLevel: Int) {
        if newLevel > currentBoatLevel && newLevel <= 3 {
            currentBoatLevel = newLevel
            // Di sini Anda bisa menambahkan animasi atau suara saat level terbuka
        }
    }
}
