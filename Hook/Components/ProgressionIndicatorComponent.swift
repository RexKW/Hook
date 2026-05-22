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
    
    // Properti Baru untuk Overlay Gembok dari GameScene
    private let lockZoneOverlay: SKShapeNode
    private let lockZoneLabel: SKLabelNode
    
    // Boat Textures
    private let teksturBoatLvl1 = SKTexture(imageNamed: "Level 1_Idle")
    private let teksturBoatLvl2 = SKTexture(imageNamed: "Level 2_Idle")
    private let teksturBoatLvl3 = SKTexture(imageNamed: "Level 3_Idle")
    
    private let batasMaksimumGame: CGFloat = -15800.0
    
    // Init menerima node langsung dari GameScene
    init(bg: SKSpriteNode, pointer: SKSpriteNode, icon: SKSpriteNode, lockOverlay: SKShapeNode, lockLabel: SKLabelNode) {
        self.indikatorBg = bg
        self.indikatorPointer = pointer
        self.zonaIcon = icon
        self.lockZoneOverlay = lockOverlay
        self.lockZoneLabel = lockLabel
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateProgress(currentState: GKState?, hookPositionY: CGFloat) {
    
        if currentState is IdleState {
            [indikatorBg, indikatorPointer, zonaIcon, lockZoneOverlay, lockZoneLabel].forEach { $0.isHidden = true }
            return
        } else {
            [indikatorBg, indikatorPointer, zonaIcon].forEach { $0.isHidden = false }
        }
        
       
        let progress = max(0.0, min(1.0, abs(hookPositionY) / abs(batasMaksimumGame)))
        
        if progress < 0.39 {
            if zonaIcon.texture != teksturBoatLvl1 { zonaIcon.texture = teksturBoatLvl1 }
        } else if progress >= 0.39 && progress < 0.63 {
            if zonaIcon.texture != teksturBoatLvl2 { zonaIcon.texture = teksturBoatLvl2 }
        } else {
            if zonaIcon.texture != teksturBoatLvl3 { zonaIcon.texture = teksturBoatLvl3 }
        }
        
        let tinggiEfektifTiang = indikatorBg.size.height - 30
        let titikBarPalingAtas = indikatorBg.position.y + (tinggiEfektifTiang / 2)
        
        indikatorPointer.position = CGPoint(
            x: indikatorBg.position.x + (indikatorBg.size.width / 2) + 12,
            y: titikBarPalingAtas - (tinggiEfektifTiang * progress)
        )
        
        guard let stateComp = entity?.component(ofType: StateComponent.self) else { return }
        let tierSkarang = stateComp.boatTier
        
        guard let hookNode = entity?.component(ofType: GKSKNodeComponent.self)?.node,
              let sceneUtama = hookNode.scene,
              let cameraNode = sceneUtama.camera else { return }
        
        let posisiYCamera = cameraNode.position.y
        let tinggiOverlay = lockZoneOverlay.frame.size.height
        
        if tierSkarang == .boatLevel1 {
            let posisiYRelatif = BoatTier.boatLevel1.rawValue - posisiYCamera
            lockZoneOverlay.isHidden = false
            lockZoneLabel.isHidden = false
            lockZoneLabel.text = "Unlock in boat level 2"
            lockZoneOverlay.position = CGPoint(x: 0, y: posisiYRelatif - (tinggiOverlay / 2))
            lockZoneLabel.position = CGPoint(x: 0, y: posisiYRelatif - 250)
        } else if tierSkarang == .boatLevel2 {
            let posisiYRelatif = BoatTier.boatLevel2.rawValue - posisiYCamera
            lockZoneOverlay.isHidden = false
            lockZoneLabel.isHidden = false
            lockZoneLabel.text = "Unlock in boat level 3"
            lockZoneOverlay.position = CGPoint(x: 0, y: posisiYRelatif - (tinggiOverlay / 2))
            lockZoneLabel.position = CGPoint(x: 0, y: posisiYRelatif - 150)
        } else {
            lockZoneOverlay.isHidden = true
            lockZoneLabel.isHidden = true
        }
    }
}
