//
//  ProgressionIndicatorComponent.swift
//  Hook
//
//  Created by Miranda Utami on 20/05/26.
//

import SpriteKit
import GameplayKit

class ProgressionIndicatorComponent: GKComponent {
    // Menyimpan referensi node visual dari GameScene
    private let indikatorBg: SKSpriteNode
    private let indikatorPointer: SKSpriteNode
    private let zonaIcon: SKSpriteNode
    
    // Boat
    private let teksturBoatLvl1 = SKTexture(imageNamed: "Level 1_Idle")
    private let teksturBoatLvl2 = SKTexture(imageNamed: "Level 2_Idle")
    private let teksturBoatLvl3 = SKTexture(imageNamed: "Level 3_Idle")
    
    private let batasMaksimumGame: CGFloat = -15800.0
    
    // Init menerima node langsung dari GameScene
    init(bg: SKSpriteNode, pointer: SKSpriteNode, icon: SKSpriteNode) {
        self.indikatorBg = bg
        self.indikatorPointer = pointer
        self.zonaIcon = icon
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateProgress(currentState: GKState?, hookPositionY: CGFloat) {
        // 1. Atur visibilitas berdasarkan Game State
        if currentState is IdleState {
            [indikatorBg, indikatorPointer, zonaIcon].forEach { $0.isHidden = true }
            return
        } else {
            [indikatorBg, indikatorPointer, zonaIcon].forEach { $0.isHidden = false }
        }
        
        // 2. Kalkulasi Progress Kedalaman
        let progress = max(0.0, min(1.0, abs(hookPositionY) / abs(batasMaksimumGame)))
        
        // 3. Update Tekstur Ikon Kapal
        if progress < 0.39 {
            if zonaIcon.texture != teksturBoatLvl1 { zonaIcon.texture = teksturBoatLvl1 }
        } else if progress >= 0.39 && progress < 0.63 {
            if zonaIcon.texture != teksturBoatLvl2 { zonaIcon.texture = teksturBoatLvl2 }
        } else {
            if zonaIcon.texture != teksturBoatLvl3 { zonaIcon.texture = teksturBoatLvl3 }
        }
        
        // 4. Perbarui Posisi Pointer Indikator terhadap Batas Bar
        let tinggiEfektifTiang = indikatorBg.size.height - 30
        let titikBarPalingAtas = indikatorBg.position.y + (tinggiEfektifTiang / 2)
        
        indikatorPointer.position = CGPoint(
            x: indikatorBg.position.x + (indikatorBg.size.width / 2) + 12,
            y: titikBarPalingAtas - (tinggiEfektifTiang * progress)
        )
    }
}
