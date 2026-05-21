//
//  GameScene.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//

import SpriteKit
import GameplayKit
import SwiftUI

class GameScene: SKScene {
    weak var gameVM: GameViewModel?
    
    /// Entities
    private var entities = [GKEntity]()
    private var hookEntity: HookEntity?
    private var wheelEntity: GKEntity!
    private var backgroundMusic: SKAudioNode?
    private var splashSound: SKAudioNode?
    private var reelingSound: SKAudioNode?
    private var cancelFishSound: SKAudioNode?
    private let mainCamera = SKCameraNode()
    var fishEntities: [FishEntity] = []
    
    
    /// Systems
    let movementSystem = GKComponentSystem(componentClass: MovementSystem.self)
    var cameraSystem = GKComponentSystem(componentClass: CameraSystem.self)
    var stateSystem = GKComponentSystem(componentClass: GameStateSystem.self)
    private var reelingSystem = GKComponentSystem(componentClass: ReelingSystem.self)
    private var reelingVisualSystem = GKComponentSystem(componentClass: ReelingVisualSystem.self)
    var fishMovementSystem = GKComponentSystem(componentClass: FishMovementSystem.self)
    var fishStateSystem = GKComponentSystem(componentClass: FishStateSystem.self)
    private let catchTargetSystem = TestCatchTargetSystem()
    private let hookSystem = CameraFollowHookSystem()
    
    /// Nodes dari .sks
    private var characterNode: SKSpriteNode!
    private var hookNode: SKSpriteNode!
    private var lineNode: SKSpriteNode!
    
    /// Nodes Indikator Progression
    private var indikatorBg: SKSpriteNode!
    private var indikatorPointer: SKSpriteNode!
    private var zonaIcon: SKSpriteNode!
    private var lockZoneOverlay: SKShapeNode!
    private var lockZoneLabel: SKLabelNode!
     
    /// Boat Level
    let teksturBoatLvl1 = SKTexture(imageNamed: "Level 1_Idle")
    let teksturBoatLvl2 = SKTexture(imageNamed: "Level 2_Idle")
    let teksturBoatLvl3 = SKTexture(imageNamed: "Level 3_Idle")
    
    /// Variables
    var rodTipPosition: CGPoint {
        return CGPoint(x: characterNode.position.x + 230, y: characterNode.position.y - 50)
    }
    var success: Bool = false
    var lastUpdateTime: TimeInterval = 0
    var possibleClouds = ["Cloud-1","Cloud-2","Cloud-3"]
    var gameTimer: Timer!
    
    var initialClouds: Bool = true
    private var elapsedTime = 0.0
    private var waitingStartedAt: TimeInterval?
    private let catchStartDelay: TimeInterval = 0.35
    
    private let seaTop: CGFloat = -847
    private var layerHeight: CGFloat {
        size.height * 2.5
    }
    private var seaBottom: CGFloat {
        seaTop - layerHeight * CGFloat(seaLayers.count)
    }
    
    private var activeFish: FishEntity? = nil
    
    private let seaLayers: [FishGenerator.SeaLayer] = [
        .epipelagic,
        .mesopelagic,
        .bathypelagic
    ]
    
    private let fishCountPerLayer = 20
    
    override func didMove(to view: SKView) {
            playBackgroundMusic()
            spawnFishInAllLayers()

            characterNode = childNode(withName: "Character2") as? SKSpriteNode
            hookNode = childNode(withName: "Hook") as? SKSpriteNode
            lineNode = childNode(withName: "Line") as? SKSpriteNode
            
            lineNode.anchorPoint = CGPoint(x: 0.5, y: 1.0)
            
            guard characterNode != nil, hookNode != nil, lineNode != nil else {
                print("❌ ERROR: Salah satu Node tidak ditemukan. Cek nama di .sks!")
                return
            }

            characterNode.zPosition = 10
            lineNode.zPosition = 11
            hookNode.zPosition = 12

            [characterNode, hookNode, lineNode].forEach { $0?.texture?.filteringMode = .nearest }
            
            setupCamera()
            setupProgressionIndicator() // Membuat bar dan tirai hitam overlay besar
            setupHook()                 // 🌟 SEKARANG AKTIF! Mengisi hookEntity secara aman
            
            if let realHookEntity = self.hookEntity {
                hookSystem.attachHook(
                    entity: realHookEntity,
                    viewportHeight: size.height
                )
            }
        }
    
    func setupHook() {
            if let node = childNode(withName: "Hook") as? SKSpriteNode {
                // Membawa seluruh parameter node visual pelacak ke dalam HookEntity
                let entity = HookEntity(node: node,
                                        camera: mainCamera,
                                        bg: self.indikatorBg,
                                        pointer: self.indikatorPointer,
                                        icon: self.zonaIcon,
                                        lockOverlay: self.lockZoneOverlay,
                                        lockLabel: self.lockZoneLabel)
                self.hookEntity = entity
                
                movementSystem.addComponent(foundIn: entity)
                cameraSystem.addComponent(foundIn: entity)
                stateSystem.addComponent(foundIn: entity)
            }
        }
    
    private func setupCamera() {
        addChild(mainCamera)
        self.camera = mainCamera
    }
    
    private func setupProgressionIndicator() {
            indikatorBg = SKSpriteNode(imageNamed: "Progression")
            indikatorPointer = SKSpriteNode(imageNamed: "Indicator")
            zonaIcon = SKSpriteNode(texture: teksturBoatLvl1)
            
            let longProgression: CGFloat = 1200.0
            let wideProgression: CGFloat = 70.0
            
            indikatorBg.size = CGSize(width: wideProgression, height: longProgression)
            indikatorPointer.size = CGSize(width: 100, height: 50)
            
            indikatorBg.zPosition = 1900
            indikatorPointer.zPosition = 2000
            zonaIcon.zPosition = 2100
            
            let overlaySize = CGSize(width: self.size.width, height: self.size.height * 2)
            lockZoneOverlay = SKShapeNode(rectOf: overlaySize)
            lockZoneOverlay.fillColor = SKColor.black.withAlphaComponent(0.5)
            lockZoneOverlay.strokeColor = .clear
            lockZoneOverlay.zPosition = 1500
            lockZoneOverlay.position = CGPoint(x: 0, y: -overlaySize.height / 2)
            
            lockZoneLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
            lockZoneLabel.text = "Unlock in boat level 2"
            lockZoneLabel.fontSize = 80
            lockZoneLabel.fontColor = .white
            lockZoneLabel.horizontalAlignmentMode = .center
            lockZoneLabel.verticalAlignmentMode = .center
            lockZoneLabel.zPosition = 1501
            lockZoneLabel.position = CGPoint(x: 0, y: -250)
            
            [indikatorBg, indikatorPointer, zonaIcon, lockZoneOverlay, lockZoneLabel].forEach { node in
                if let node = node {
                    if node is SKSpriteNode { (node as! SKSpriteNode).texture?.filteringMode = .nearest }
                    mainCamera.addChild(node)
                }
            }
            
            let setengahLebarScene = self.size.width / 2
            let posisiX = -setengahLebarScene + 100
            let posisiY: CGFloat = 40
            
            indikatorBg.position = CGPoint(x: posisiX, y: posisiY)
            zonaIcon.size = CGSize(width: 160, height: 160)
            zonaIcon.position = CGPoint(x: posisiX + 10, y: posisiY + (indikatorBg.size.height / 2) + 40)
            
            [indikatorBg, indikatorPointer, zonaIcon, lockZoneOverlay, lockZoneLabel].forEach { $0?.isHidden = true }
        }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Hold!")
        guard let entity = hookEntity,
            let input = hookEntity?.component(ofType: InputComponent.self),
            let stateComp = entity.component(ofType: StateComponent.self) else {
            print("❌ Error: InputComponent / StateComponent tidak ditemukan di Entity!")
            return
        }
        
        input.handleTouchBegan()
        print("isHolding sekarang: \(input.isHolding)")
        
        let currentState = stateComp.stateMachine.currentState
                
        if currentState is IdleState {
            print("casting")
            playSplashSound()
            stateComp.stateMachine.enter(CastingState.self)
            self.gameVM?.isGameTime = true
        }
        
        if currentState is WaitingState {
            if input.isTapped {
                stateComp.stateMachine.enter(CancelState.self)
                
            }
        }
        
        if currentState is ReelingState {
            guard let wheel = wheelEntity,
                  let logic = wheel.component(ofType: ReelingSystem.self),
                  let variables = wheel.component(ofType: ReelingComponent.self) else {
                    print("⏳ Waiting for wheelEntity to be created...")
                    return
                }
            
            if variables.catchProgress >= 1.0 {
                print("Fish already caught! Resetting...")
                variables.catchProgress = 0.0
                return
            }
            
            success = logic.attemptReel()
            
            if success {
                print("Hit! Progress: \(variables.catchProgress)")
                playReelingSound()
                logic.randomizeTarget()
                variables.rotationSpeed += 0.2
                elapsedTime = 0
                
            } else {
                print("Miss! Fish pulling away. Progress: \(variables.catchProgress)")
                if variables.catchProgress <= 0.0 {
                    print("Fish escaped back to 0 progress...")
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        hookEntity?.component(ofType: InputComponent.self)?.handleTouchEnded()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 { lastUpdateTime = currentTime }
        let dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        elapsedTime += dt

        guard let entity = hookEntity,
              let stateComp = entity.component(ofType: StateComponent.self) else { return }
        
        let currentState = stateComp.stateMachine.currentState
        
        if currentState is ReelingState && wheelEntity == nil {
            setupReeling()
            
        }
        
        if currentState is IdleState {
            self.gameVM?.isGameTime = false
            wheelEntity = nil
            hookNode.position = CGPoint(x: rodTipPosition.x - 5 , y: rodTipPosition.y - 20)
        } else {
            if let movement = entity.component(ofType: MovementSystem.self) {
                movement.update(deltaTime: dt, rodTip: rodTipPosition)
            }
        }
        
        if stateComp.stateMachine.currentState is CancelState {
            catchTargetSystem.resetCatchSession()
        }
        
        if success == true {
            if elapsedTime >= 0.5 || mainCamera.position.y >= 740 {
                success = false
                elapsedTime = 0
            } else {
                hookNode.position.y += 10.0
                if currentState is ReelingState && hookNode.position.y >= seaTop {
                    finishCaughtFish(stateComp: stateComp)
                    return
                }
            }
        }
        
        if currentState is CancelState {
            playCancelFishSound()
            hookNode.position.y += 15.0
            if hookNode.position.y >= seaTop {
                stateComp.stateMachine.enter(IdleState.self)
            }
        }
        
        if !(currentState is IdleState) && hookNode.position.y >= seaTop {
                    mainCamera.childNode(withName: "Wheel")?.removeFromParent()
                    catchTargetSystem.resetCatchSession()
                    stateComp.stateMachine.enter(IdleState.self)
        }

        stateSystem.update(deltaTime: dt)
        cameraSystem.update(deltaTime: dt)

        updateLineVisual()
        reelingSystem.update(deltaTime: dt)
        reelingVisualSystem.update(deltaTime: dt)
        movementSystem.update(deltaTime: dt)
        fishStateSystem.update(deltaTime: dt)
        fishMovementSystem.update(deltaTime: dt)
        hookSystem.update()
        updateCatchTarget(currentTime: currentTime)

        removeInvalidFishEntities()
        keepFishCountBalancedAcrossLayers()

        entity.component(ofType: InputComponent.self)?.isTapped = false
        
        updateMekanikIndikator()
        
        if let indicator = entity.component(ofType: ProgressionIndicatorComponent.self) {
                    indicator.updateProgress(currentState: currentState, hookPositionY: hookNode.position.y)
        }
    }
    
    private func finishCaughtFish(stateComp: StateComponent) {
        print("FISH CAUGHT! You win!")
        success = false
        elapsedTime = 0
        hookNode.position.y = seaTop
        hookSystem.removeAttachedFish()
        
        if let wheel = wheelEntity,
           let variables = wheel.component(ofType: ReelingComponent.self) {
            variables.rotationSpeed = 0
        }
        
        if let rodaPancing = mainCamera.childNode(withName: "Wheel") {
            rodaPancing.removeFromParent()
        }
        
        if let wheel = wheelEntity,
           let index = entities.firstIndex(of: wheel) {
            entities.remove(at: index)
        }
        
        DispatchQueue.main.async { [weak self] in
                guard let self = self, let caughtFish = self.activeFish else { return }
                
                if let fishData = caughtFish.component(ofType: FishMovementComponent.self) {
                    
                    let newFish = FishModel(
                        imageName: fishData.textureName,
                        weightKg: fishData.weight
                    )
                    
                    self.gameVM?.caughtFish = newFish
                }
                activeFish = nil
            
                self.gameVM?.isGameTime = false
            }
        
        
    
        
        wheelEntity = nil
        mainCamera.removeAllChildren()
        setupProgressionIndicator()
        catchTargetSystem.resetCatchSession()
        stateComp.stateMachine.enter(IdleState.self)
    }
    
    func updateMekanikIndikator() {
        guard let entity = hookEntity,
              let stateComp = entity.component(ofType: StateComponent.self) else { return }
        
        let currentState = stateComp.stateMachine.currentState
        
        guard indikatorBg != nil, indikatorPointer != nil, zonaIcon != nil else { return }
        
        if currentState is IdleState {
            [indikatorBg, indikatorPointer, zonaIcon].forEach { $0?.isHidden = true }
            return
        } else {
            [indikatorBg, indikatorPointer, zonaIcon].forEach { $0?.isHidden = false }
        }
        
        let batasMaksimumGame: CGFloat = -15800.0
        let posisiHookY = hookNode.position.y
        let progress = max(0.0, min(1.0, abs(posisiHookY) / abs(batasMaksimumGame)))
        
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
    }
    
    func updateLineVisual() {
        let start = rodTipPosition
        let end = hookNode.position
        
        lineNode.position = start
        
        let distance = abs(start.y - end.y)
        let textureHeight = lineNode.texture?.size().height ?? 1.0
            
        lineNode.yScale = max(0.01, distance / textureHeight)
        lineNode.zRotation = 0
    }

    @objc func randomAddClouds () {
        let randomNumber = GKRandomSource.sharedRandom().nextInt(upperBound: 2) + 1
        for _ in 1...randomNumber {
            addCloud(initialCloud: initialClouds)
        }
        initialClouds = false
    }
    
    @objc func addCloud (initialCloud: Bool) {
        possibleClouds = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleClouds) as! [String]
        let cloud = SKSpriteNode(imageNamed: possibleClouds[0])
        cloud.zPosition = 1
        
        let rightEdge = (self.frame.size.width / 2) + cloud.size.width
        let leftEdge = -(self.frame.size.width / 2) - cloud.size.width
        
        let randomCloudYPosition = GKRandomDistribution(lowestValue: 720, highestValue: 1920)
        let randomCloudDirection = GKRandomSource.sharedRandom().nextInt(upperBound: 2) == 0
        let positionY = CGFloat(randomCloudYPosition.nextInt())
        
        if initialCloud {
            let randomCloudXPosition = GKRandomDistribution(lowestValue: -320, highestValue: 320)
            let positionX = CGFloat(randomCloudXPosition.nextInt())
            cloud.position = CGPoint(x: positionX, y: positionY)
        } else {
            if randomCloudDirection {
                cloud.position = CGPoint(x: rightEdge, y: positionY)
            } else {
                cloud.position = CGPoint(x: leftEdge, y: positionY)
            }
        }
        
        self.addChild(cloud)
        let animationDuration: TimeInterval = 60
        var actionArray = [SKAction]()
        
        if randomCloudDirection {
            actionArray.append(SKAction.move(to: CGPoint(x: leftEdge, y: positionY), duration: animationDuration))
        } else {
            actionArray.append(SKAction.move(to: CGPoint(x: rightEdge, y: positionY), duration: animationDuration))
        }
        
        actionArray.append(SKAction.removeFromParent())
        cloud.run(SKAction.sequence(actionArray))
    }

    func setupReeling() {
        let wheelNode = SKSpriteNode()
        wheelNode.name = "Wheel"
        wheelNode.position = CGPoint(x: 0, y: 0)

        wheelNode.zPosition = 1000
        
        mainCamera.addChild(wheelNode)
        self.wheelEntity = WheelEntity(node: wheelNode)
        self.entities.append(self.wheelEntity)
        
        reelingSystem.addComponent(foundIn: self.wheelEntity)
        reelingVisualSystem.addComponent(foundIn: self.wheelEntity)

        if let visualComponent = wheelEntity.component(ofType: ReelingVisualComponent.self) {
            visualComponent.rootNode.removeFromParent()
            visualComponent.rootNode.position = CGPoint(x: 0.0, y: 0.0)
            visualComponent.rootNode.zPosition = 1
            wheelNode.addChild(visualComponent.rootNode)
        }
    }
    
    ///Fish Code
    private func keepFishCountBalancedAcrossLayers() {
        for layer in seaLayers {
            let currentCount = fishEntities.filter {
                $0.component(ofType: FishMovementComponent.self)?.layer == layer
            }.count
            
            if currentCount < fishCountPerLayer {
                for _ in 0..<(fishCountPerLayer - currentCount) {
                    spawnFish(layer: layer)
                }
            }
        }
    }
    
    private func spawnFish(layer: FishGenerator.SeaLayer) {
        FishGenerator.spawnFish(
            in: self,
            fishEntities: &fishEntities,
            layer: layer
        )

        if let movementComponent = fishEntities.last?.component(
            ofType: FishMovementSystem.self
        ) {
            fishMovementSystem.addComponent(
                movementComponent
            )
        }
        
        if let stateComponent = fishEntities.last?.component(
            ofType: FishStateSystem.self
        ) {
            fishStateSystem.addComponent(
                stateComponent
            )
        }
    }
    
    private func spawnFishInAllLayers() {
        for layer in seaLayers {
            for _ in 0..<fishCountPerLayer {
                spawnFish(layer: layer)
            }
        }
    }
    
    private func removeInvalidFishEntities() {
        let invalidFish = fishEntities.filter {
            $0.component(ofType: GKSKNodeComponent.self)?.node.parent == nil
        }
        
        for fish in invalidFish {
            if let movementComponent = fish.component(ofType: FishMovementSystem.self) {
                fishMovementSystem.removeComponent(movementComponent)
            }
            
            if let stateComponent = fish.component(ofType: FishStateSystem.self) {
                fishStateSystem.removeComponent(stateComponent)
            }
        }
        
        fishEntities.removeAll {
            $0.component(ofType: GKSKNodeComponent.self)?.node.parent == nil
        }
    }
    
    private func layer(for yPosition: CGFloat) -> FishGenerator.SeaLayer {
        if yPosition >= seaTop - layerHeight {
            return .epipelagic
        } else if yPosition >= seaTop - layerHeight * 2 {
            return .mesopelagic
        } else {
            return .bathypelagic
        }
    }
    
    private func moveCamera(by deltaY: CGFloat) {
        guard let camera else { return }

        let halfHeight = size.height / 2
        let minY = seaBottom + halfHeight
        let maxY = seaTop - halfHeight

        let newY = camera.position.y + deltaY
        camera.position.y = min(max(newY, minY), maxY)
    }
    
    private func updateCatchTarget(currentTime: TimeInterval) {
        guard let entity = hookEntity,
            let stateComp = entity.component(ofType: StateComponent.self)
        else {
            print("❌ Error: InputComponent tidak ditemukan di Entity!")
            return
        }
        
        guard stateComp.stateMachine.currentState is WaitingState else {
            waitingStartedAt = nil
            return
        }
        
        if waitingStartedAt == nil {
            waitingStartedAt = currentTime
            return
        }
        
        guard let waitingStartedAt,
              currentTime - waitingStartedAt >= catchStartDelay else {
            return
        }
        
        if catchTargetSystem.tryCatchFish(
                from: fishEntities,
                hookPosition: hookNode.position,
                hookLayer: layer(for: hookNode.position.y),
                currentTime: currentTime,
                onHooked: { [weak self] caughtFish in
                    guard let self,
                          stateComp.stateMachine.currentState is WaitingState else {
                        return
                    }
                    activeFish = caughtFish
//                    gameVM.caughtFish = caughtFish.component(ofType: FishMovementComponent.self)
                    stateComp.stateMachine.enter(ReelingState.self)
                    hookSystem.attachCaughtFish(
                        caughtFish,
                        in: self
                    )
                },
                onFailed: { _ in
                    stateComp.stateMachine.enter(WaitingState.self)
                }
            ) != nil { }
    }
    
    ///Audio System
    private func playBackgroundMusic() {
        guard backgroundMusic == nil else { return }

        let songs = [
            "Harbor Morning Drift.mp3",
            "Morning at the Lake.mp3",
            "Tidepool Lantern.mp3",
            "Tidewood Dock.mp3",
            "Willow Dock Drift.mp3"
        ]
        guard let song = songs.randomElement() else { return }

        let music = SKAudioNode(fileNamed: song)
        music.autoplayLooped = true
        music.isPositional = false
        music.run(SKAction.changeVolume(to: 0, duration: 0))
        addChild(music)

        music.run(SKAction.changeVolume(to: 1, duration: 1.5))
        backgroundMusic = music
    }
    
    private func fadeOutBackgroundMusic(duration: TimeInterval = 1.5) {
        guard let backgroundMusic else { return }
        
        backgroundMusic.run(
            SKAction.sequence([
                SKAction.changeVolume(to: 0, duration: duration),
                SKAction.removeFromParent(),
                SKAction.run { [weak self] in
                    self?.backgroundMusic = nil
                }
            ])
        )
    }
    
    private func playSplashSound(duration: TimeInterval = 1.5) {
        let audioPath = "Mountain Audio - Splash.mp3"
        let splashSoundEffect = SKAudioNode(fileNamed: audioPath)
        splashSoundEffect.autoplayLooped = false
        splashSoundEffect.isPositional = false
        splashSoundEffect.run(SKAction.changeVolume(to: 1, duration: 0))
        addChild(splashSoundEffect)
        
        splashSoundEffect.run(
            SKAction.sequence([
                SKAction.play(),
                SKAction.wait(forDuration: duration),
                SKAction.removeFromParent()
            ])
        )
    }
    
    private func playCancelFishSound(duration: TimeInterval = 1){
        guard cancelFishSound == nil else { return }
        let audioPath = "Fishing Game Action.wav"
        let cancelFishSoundEffect = SKAudioNode(fileNamed: audioPath)
        cancelFishSoundEffect.autoplayLooped = false
        cancelFishSoundEffect.isPositional = false
        cancelFishSoundEffect.run(SKAction.changeVolume(to: 1, duration: 0))
        addChild(cancelFishSoundEffect)
        cancelFishSound = cancelFishSoundEffect
        
        cancelFishSoundEffect.run(
            SKAction.sequence([
                SKAction.play(),
                SKAction.wait(forDuration: duration),
                SKAction.removeFromParent(),
                SKAction.run { [weak self] in
                    self?.cancelFishSound = nil
                }
            ])
        )
    }
    
    private func playReelingSound(duration: TimeInterval = 0.5) {
        guard reelingSound == nil else { return }
        
        let audioPath = "Fishing Reeling Reel.wav"
        let reelingSoundEffect = SKAudioNode(fileNamed: audioPath)
        reelingSoundEffect.autoplayLooped = false
        reelingSoundEffect.isPositional = false
        reelingSoundEffect.run(SKAction.changeVolume(to: 1, duration: 0))
        addChild(reelingSoundEffect)
        reelingSound = reelingSoundEffect
        
        reelingSoundEffect.run(
            SKAction.sequence([
                SKAction.play(),
                SKAction.wait(forDuration: duration),
                SKAction.removeFromParent(),
                SKAction.run { [weak self] in
                    self?.reelingSound = nil
                }
            ])
        )
    }
}
