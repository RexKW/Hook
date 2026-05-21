//
//  TopBarView.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 20/05/26.
//

import SwiftUI

struct TopBarView: View {
    @Binding var isUpgradeMenuPresented: Bool
    
    @Binding var isFishCollectionPresented: Bool
    
    @Binding var currentBoatLevel: Int
    
    @Binding var playerProgress: CGFloat
    
    var body: some View {
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
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isFishCollectionPresented.toggle()
                }
            }) {
                Image("ButtonBook")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
            }
            .padding(12)
            
        }
    }
    
    
}



#Preview {
    TopBarView(
        isUpgradeMenuPresented: .constant(false),
        isFishCollectionPresented: .constant(false),
        currentBoatLevel: .constant(1),
        playerProgress: .constant(CGFloat(0.25))
    )
}
