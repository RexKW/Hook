//
//  UpgradePopUpView.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 20/05/26.
//

import SwiftUI

struct UpgradePopUpView: View {
    @Binding var isUpgradeMenuPresented: Bool
    @Binding var currentBoatLevel: Int
    
    var body: some View {
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
            .accessibilityIdentifier("upgradeCloseButton")
            .accessibilityLabel("Close Upgrade")
        }
        .accessibilityIdentifier("upgradePopup")
    }
    
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
}

#Preview {
    UpgradePopUpView(
        isUpgradeMenuPresented: .constant(false),
        currentBoatLevel: .constant(1),
    )
}
