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
                    ZStack{
                        Image("ButtonLevel")
                            .resizable()
                            .frame(width:50, height: 50)
                        Text("\(currentBoatLevel)")
                            .font(.custom("RawPixel-Bold", size: 28))
                            .frame(width: 50, height: 50)

                            .foregroundColor(Color(red: 0.443, green: 0.259, blue: 0.188) )
    
                    }
                    
                    
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
