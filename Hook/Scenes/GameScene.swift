//
//  GameScene.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    /// Entities
    private var entities = [GKEntity]()
    private var hookEntity: HookEntity?
    private var wheelEntity: GKEntity!
    var fishEntities: [FishEntity] = []
    
    /// Camera
    private let mainCamera = SKCameraNode()
    
    /// Casting Nodes
    private var characterNode: SKSpriteNode!
    private var hookNode: SKSpriteNode!
    private var lineNode: SKSpriteNode!
    
    /// Indikator Progression Nodes
    private var indikatorBg: SKSpriteNode!
    private var indikatorPointer: SKSpriteNode!
    private var zonaIcon: SKSpriteNode!
    private var lockZoneOverlay: SKShapeNode!
    private var lockZoneLabel: SKLabelNode!   
    
    /// Audio Nodes
    private var backgroundMusic: SKAudioNode?
    private var splashSound: SKAudioNode?
    private var reelingSound: SKAudioNode?
    
    /// Systems (ECS GKComponentSystems)
    let movementSystem = GKComponentSystem(componentClass: MovementSystem.self)
    var cameraSystem = GKComponentSystem(componentClass: CameraSystem.self)
    var stateSystem = GKComponentSystem(componentClass: GameStateSystem.self)
    var fishMovementSystem = GKComponentSystem(componentClass: FishMovementSystem.self)
    var fishStateSystem = GKComponentSystem(componentClass: FishStateSystem.self)
    
    private var reelingSystem = GKComponentSystem(componentClass: ReelingSystem.self)
    private var reelingVisualSystem = GKComponentSystem(componentClass: ReelingVisualSystem.self)
    private let catchTargetSystem = TestCatchTargetSystem()
    private let hookSystem = CameraFollowHookSystem()
    
    /// Gameplay Configurations & Variables
    var rodTipPosition: CGPoint {
        return CGPoint(x: characterNode.position.x + 230, y: characterNode.position.y - 50)
    }
    
    var success: Bool = false
    var lastUpdateTime: TimeInterval = 0
    var possibleClouds = ["Cloud-1", "Cloud-2", "Cloud-3"]
    var gameTimer: Timer!
    var initialClouds: Bool = true
    
    private var elapsedTime = 0.0
    private let seaTop: CGFloat = -847
    private var layerHeight: CGFloat { size.height * 2.5 }
    private var seaBottom: CGFloat { seaTop - layerHeight * CGFloat(seaLayers.count) }
    private let fishCountPerLayer = 20
    private let seaLayers: [FishGenerator.SeaLayer] = [.epipelagic, .mesopelagic, .bathypelagic]
    
    // MARK: - Scene Lifecycle
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
        setupProgressionIndicator() // Harus dipanggil duluan agar node tercipta
        setupHook()                 // Membawa referensi node yang sudah aman terbentuk
        
        if let realHookEntity = self.hookEntity {
            hookSystem.attachHook(entity: realHookEntity, viewportHeight: size.height)
        }
    }
    
    // MARK: - Initializations
    func setupHook() {
        if let node = childNode(withName: "Hook") as? SKSpriteNode {
            // Membawa seluruh parameter node visual pelacak ke dalam HookEntity
            let entity = HookEntity(node: node,
                                    camera: mainCamera,
                                    bg: self.indikatorBg,
                                    pointer: self.indikatorPointer,
                                    icon: self.zonaIcon,
                                    lockOverlay: self.lockZoneOverlay, // Parameter baru aman
                                    lockLabel: self.lockZoneLabel)     // Parameter baru aman
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
        zonaIcon = SKSpriteNode(texture: SKTexture(imageNamed: "Level 1_Idle"))
        
        let longProgression: CGFloat = 1200.0
        let wideProgression: CGFloat = 70.0
        
        indikatorBg.size = CGSize(width: wideProgression, height: longProgression)
        indikatorPointer.size = CGSize(width: 100, height: 50)
        
        indikatorBg.zPosition = 1900
        indikatorPointer.zPosition = 2000
        zonaIcon.zPosition = 2100
        
        // 🌟 PERBAIKAN: Alokasi Fisik Node Overlay dan Teks Sebelum Digunakan
        let overlaySize = CGSize(width: self.size.width, height: self.size.height * 1.5)
        lockZoneOverlay = SKShapeNode(rectOf: overlaySize)
        lockZoneOverlay.fillColor = SKColor.black.withAlphaComponent(0.5)
        lockZoneOverlay.strokeColor = .clear
        lockZoneOverlay.zPosition = 1500
        lockZoneOverlay.position = CGPoint(x: 0, y: -overlaySize.height / 2)
        
        lockZoneLabel = SKLabelNode(fontNamed: "AvenirNext-Bold") // Gunakan font bawaan iOS yang aman
        lockZoneLabel.text = "Unlock in boat level 2"
        lockZoneLabel.fontSize = 32
        lockZoneLabel.fontColor = .lightGray
        lockZoneLabel.horizontalAlignmentMode = .center
        lockZoneLabel.verticalAlignmentMode = .center
        lockZoneLabel.zPosition = 1501
        lockZoneLabel.position = CGPoint(x: 0, y: -200)
        
        // Masukkan semua node yang telah terbentuk ke dalam kamera utama
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
        
        // Sekarang array ini aman dieksekusi tanpa memicu Unwrapped Optional Crash
        [indikatorBg, indikatorPointer, zonaIcon, lockZoneOverlay, lockZoneLabel].forEach { $0?.isHidden = true }
    }
    
    func setupReeling() {
        let wheelNode = SKSpriteNode()
        wheelNode.name = "Wheel"
        wheelNode.position = .zero
        wheelNode.zPosition = 1000
        
        mainCamera.addChild(wheelNode)
        self.wheelEntity = WheelEntity(node: wheelNode)
        self.entities.append(self.wheelEntity)
        
        reelingSystem.addComponent(foundIn: self.wheelEntity)
        reelingVisualSystem.addComponent(foundIn: self.wheelEntity)

        if let visualComponent = wheelEntity.component(ofType: ReelingVisualComponent.self) {
            visualComponent.rootNode.removeFromParent()
            visualComponent.rootNode.position = .zero
            visualComponent.rootNode.zPosition = 1
            wheelNode.addChild(visualComponent.rootNode)
        }
    }
    
    // MARK: - Input Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let entity = hookEntity,
              let input = hookEntity?.component(ofType: InputComponent.self),
              let stateComp = entity.component(ofType: StateComponent.self) else { return }
        
        input.handleTouchBegan()
        let currentState = stateComp.stateMachine.currentState
                
        if currentState is IdleState {
            stateComp.stateMachine.enter(CastingState.self)
        }
        
        if currentState is WaitingState && input.isTapped {
            stateComp.stateMachine.enter(CancelState.self)
        }
        
        if currentState is ReelingState {
            guard let wheel = wheelEntity,
                  let logic = wheel.component(ofType: ReelingSystem.self),
                  let variables = wheel.component(ofType: ReelingComponent.self) else { return }
            
            if variables.catchProgress >= 1.0 {
                variables.catchProgress = 0.0
                return
            }
            
            success = logic.attemptReel()
            
            if success {
                logic.randomizeTarget()
                variables.rotationSpeed += 0.2
                elapsedTime = 0
                
                if hookNode.position.y >= -847 {
                    variables.rotationSpeed = 0
                    mainCamera.childNode(withName: "Wheel")?.removeFromParent()
                    if let index = entities.firstIndex(of: wheel) { entities.remove(at: index) }
                    stateComp.stateMachine.enter(IdleState.self)
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        hookEntity?.component(ofType: InputComponent.self)?.handleTouchEnded()
    }
    
    // MARK: - Main Update Game Loop
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
            wheelEntity = nil
            hookNode.position = CGPoint(x: rodTipPosition.x - 5, y: rodTipPosition.y - 20)
        } else {
            entity.component(ofType: MovementSystem.self)?.update(deltaTime: dt, rodTip: rodTipPosition)
        }
        
        if success {
            if elapsedTime >= 0.5 || mainCamera.position.y >= 740 {
                success = false
                elapsedTime = 0
            } else {
                hookNode.position.y += 10.0
            }
        }
        
        if currentState is CancelState {
            hookNode.position.y += 15.0
            if hookNode.position.y >= -847 { stateComp.stateMachine.enter(IdleState.self) }
        }
        
        if hookNode.position.y >= -847 {
            mainCamera.childNode(withName: "Wheel")?.removeFromParent()
            catchTargetSystem.resetCatchSession()
            stateComp.stateMachine.enter(IdleState.self)
        }

        // Ticks Systems Update
        stateSystem.update(deltaTime: dt)
        cameraSystem.update(deltaTime: dt)
        reelingSystem.update(deltaTime: dt)
        reelingVisualSystem.update(deltaTime: dt)
        movementSystem.update(deltaTime: dt)
        fishStateSystem.update(deltaTime: dt)
        fishMovementSystem.update(deltaTime: dt)
        hookSystem.update()
        
        // Internal Logic Updates
        updateLineVisual()
        updateCatchTarget(currentTime: currentTime)
        removeInvalidFishEntities()
        keepFishCountBalancedAcrossLayers()

        entity.component(ofType: InputComponent.self)?.isTapped = false
        
        if let indicator = entity.component(ofType: ProgressionIndicatorComponent.self) {
            indicator.updateProgress(currentState: currentState, hookPositionY: hookNode.position.y)
        }
    }
    
    // MARK: - Graphics Render
    func updateLineVisual() {
        let start = rodTipPosition
        let end = hookNode.position
        
        lineNode.position = start
        let distance = abs(start.y - end.y)
        let textureHeight = lineNode.texture?.size().height ?? 1.0
            
        lineNode.yScale = max(0.01, distance / textureHeight)
        lineNode.zRotation = 0
    }

    // MARK: - Environment Spawners (Clouds)
    @objc func randomAddClouds() {
        let randomNumber = GKRandomSource.sharedRandom().nextInt(upperBound: 2) + 1
        for _ in 1...randomNumber { addCloud(initialCloud: initialClouds) }
        initialClouds = false
    }
    
    @objc func addCloud(initialCloud: Bool) {
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
            cloud.position = CGPoint(x: CGFloat(randomCloudXPosition.nextInt()), y: positionY)
        } else {
            cloud.position = CGPoint(x: randomCloudDirection ? rightEdge : leftEdge, y: positionY)
        }
        
        self.addChild(cloud)
        let animationDuration: TimeInterval = 60
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: randomCloudDirection ? leftEdge : rightEdge, y: positionY), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        cloud.run(SKAction.sequence(actionArray))
    }
    
    // MARK: - Fish Spawners
    private func keepFishCountBalancedAcrossLayers() {
        for layer in seaLayers {
            let currentCount = fishEntities.filter {
                $0.component(ofType: FishMovementComponent.self)?.layer == layer
            }.count
            
            if currentCount < fishCountPerLayer {
                for _ in 0..<(fishCountPerLayer - currentCount) { spawnFish(layer: layer) }
            }
        }
    }
    
    private func spawnFish(layer: FishGenerator.SeaLayer) {
        FishGenerator.spawnFish(in: self, fishEntities: &fishEntities, layer: layer)

        if let movementComponent = fishEntities.last?.component(ofType: FishMovementSystem.self) {
            fishMovementSystem.addComponent(movementComponent)
        }
        if let stateComponent = fishEntities.last?.component(ofType: FishStateSystem.self) {
            fishStateSystem.addComponent(stateComponent)
        }
    }
    
    private func spawnFishInAllLayers() {
        for layer in seaLayers {
            for _ in 0..<fishCountPerLayer { spawnFish(layer: layer) }
        }
    }
    
    private func removeInvalidFishEntities() {
        let invalidFish = fishEntities.filter { $0.component(ofType: GKSKNodeComponent.self)?.node.parent == nil }
        
        for fish in invalidFish {
            if let movementComponent = fish.component(ofType: FishMovementSystem.self) {
                fishMovementSystem.removeComponent(movementComponent)
            }
            if let stateComponent = fish.component(ofType: FishStateSystem.self) {
                fishStateSystem.removeComponent(stateComponent)
            }
        }
        fishEntities.removeAll { $0.component(ofType: GKSKNodeComponent.self)?.node.parent == nil }
    }
    
    private func layer(for yPosition: CGFloat) -> FishGenerator.SeaLayer {
        if yPosition >= seaTop - layerHeight { return .epipelagic }
        if yPosition >= seaTop - layerHeight * 2 { return .mesopelagic }
        return .bathypelagic
    }
    
    private func moveCamera(by deltaY: CGFloat) {
        guard let camera else { return }
        let halfHeight = size.height / 2
        let newY = camera.position.y + deltaY
        camera.position.y = min(max(newY, seaBottom + halfHeight), seaTop - halfHeight)
    }
    
    private func updateCatchTarget(currentTime: TimeInterval) {
        guard let entity = hookEntity,
              let stateComp = entity.component(ofType: StateComponent.self) else { return }
        
        if stateComp.stateMachine.currentState is WaitingState {
            _ = catchTargetSystem.tryCatchFish(
                from: fishEntities,
                hookPosition: hookNode.position,
                hookLayer: layer(for: hookNode.position.y),
                currentTime: currentTime,
                onHooked: { [weak self] caughtFish in
                    guard let self else { return }
                    stateComp.stateMachine.enter(ReelingState.self)
                    self.hookSystem.attachCaughtFish(caughtFish, in: self)
                },
                onFailed: { _ in
                    stateComp.stateMachine.enter(WaitingState.self)
                }
            )
        }
    }
    
    // MARK: - Audio Systems
    private func playBackgroundMusic() {
        guard backgroundMusic == nil else { return }
        let songs = ["Harbor Morning Drift.mp3", "Morning at the Lake.mp3", "Tidepool Lantern.mp3", "Tidewood Dock.mp3", "Willow Dock Drift.mp3"]
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
        backgroundMusic.run(SKAction.sequence([
            SKAction.changeVolume(to: 0, duration: duration),
            SKAction.removeFromParent(),
            SKAction.run { [weak self] in self?.backgroundMusic = nil }
        ]))
    }
    
    private func playSplashSound(duration: TimeInterval = 1.5) {
        let splashSoundEffect = SKAudioNode(fileNamed: "Mountain Audio - Splash.mp3")
        splashSoundEffect.autoplayLooped = false
        splashSoundEffect.isPositional = false
        addChild(splashSoundEffect)
        
        splashSoundEffect.run(SKAction.sequence([
            SKAction.play(),
            SKAction.wait(forDuration: duration),
            SKAction.removeFromParent()
        ]))
    }
    
    private func playReelingSound(duration: TimeInterval = 1.5) {
        guard reelingSound == nil else { return }
        let reelingSoundEffect = SKAudioNode(fileNamed: "Fishing Reeling Reel.wav")
        reelingSoundEffect.autoplayLooped = false
        reelingSoundEffect.isPositional = false
        addChild(reelingSoundEffect)
        reelingSound = reelingSoundEffect
        
        reelingSoundEffect.run(SKAction.sequence([
            SKAction.play(),
            SKAction.wait(forDuration: duration),
            SKAction.removeFromParent(),
            SKAction.run { [weak self] in self?.reelingSound = nil }
        ]))
    }
}
