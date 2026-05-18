//
//  TestGameScene.swift
//  Hook
//
//  Created by Christianto Elvern Haryanto on 12/05/26.
//

import SpriteKit
import GameplayKit
import UIKit

class TestGameScene: SKScene {
    private let sceneCamera = SKCameraNode()
    private var backgroundMusic: SKAudioNode?
    private var splashSound: SKAudioNode?
    private var reelingSound: SKAudioNode?
    private var fishCaughtSound: SKAudioNode?
    private var isHookCastActive = false
    private var isHoldingScreen = false
    private var isWaitingForFish = false
    private var isReturnTapPending = false
    private var stoppedBaitPosition: CGPoint?
    private var touchStartTime: TimeInterval = 0
    private var lastUpdateTime: TimeInterval?
    private let tapDurationLimit: TimeInterval = 0.2
    private let cameraFallSpeed: CGFloat = 320
    private let heavyImpactFeedBack = UIImpactFeedbackGenerator(style: .heavy)
    
    private let seaTop: CGFloat = 0
    private var layerHeight: CGFloat {
        size.height * 2.5
    }
    private var seaBottom: CGFloat {
        seaTop - layerHeight * CGFloat(seaLayers.count)
    }
    
    var fishEntities: [FishEntity] = []
    var fishMovementSystem = GKComponentSystem(componentClass: FishMovementSystem.self)
    var fishStateSystem = GKComponentSystem(componentClass: FishStateSystem.self)
    private let hookSystem = CameraFollowHookSystem()
    private let catchTargetSystem = TestCatchTargetSystem()
    
    private let seaLayers: [FishGenerator.SeaLayer] = [
        .epipelagic,
        .mesopelagic,
        .bathypelagic
    ]
    
    private let fishCountPerLayer = 20
    
    
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

        music.run(SKAction.changeVolume(to: 0.6, duration: 1.5))
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
    
    private func playFishCaughtSound(duration: TimeInterval = 1.5){
        let audioPath = "Fishing Game Action.wav"
        let fishCaughtSoundEffect = SKAudioNode(fileNamed: audioPath)
        fishCaughtSoundEffect.autoplayLooped = false
        fishCaughtSoundEffect.isPositional = false
        fishCaughtSoundEffect.run(SKAction.changeVolume(to: 1, duration: 0))
        addChild(fishCaughtSoundEffect)
        
        fishCaughtSoundEffect.run(
            SKAction.sequence([
                SKAction.play(),
                SKAction.wait(forDuration: duration),
                SKAction.removeFromParent()
            ])
        )
    }
    
    private func playReelingSound(duration: TimeInterval = 1.5) {
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
    
    override func didMove(to view: SKView) {
        playBackgroundMusic()
        setupCamera()
        hookSystem.attachHook(
            to: sceneCamera,
            viewportHeight: size.height
        )
        spawnFishInAllLayers()
        drawLayerDivider(at: seaTop - layerHeight)
        drawLayerDivider(at: seaTop - layerHeight * 2)
    }
    
    override func update(_ currentTime: TimeInterval) {
        let deltaTime = currentTime - (lastUpdateTime ?? currentTime)
        lastUpdateTime = currentTime
        
        fishStateSystem.update(deltaTime: deltaTime)
        fishMovementSystem.update(deltaTime: deltaTime)
        hookSystem.update()
        updateCameraFall(deltaTime: deltaTime)
        updateCatchTarget(currentTime: currentTime)

        removeInvalidFishEntities()
        keepFishCountBalancedAcrossLayers()
    }
    
    private func setupCamera() {
        sceneCamera.position = CGPoint(x: 0, y: seaTop - size.height / 2)
        camera = sceneCamera
        addChild(sceneCamera)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        if isHookCastActive {
            guard stoppedBaitPosition != nil, isHoldingScreen == false else {
                return
            }
            
            isReturnTapPending = true
            touchStartTime = touch.timestamp
            return
        }
        // Play splash sfx
        playSplashSound()
        isHookCastActive = true
        isReturnTapPending = false
        sceneCamera.removeAction(forKey: "returnToBase")
        catchTargetSystem.resetCatchSession()
        stoppedBaitPosition = nil
        isWaitingForFish = false
        touchStartTime = touch.timestamp
        isHoldingScreen = true
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            isHoldingScreen = false
            isReturnTapPending = false
            return
        }
        
        if isReturnTapPending {
            isReturnTapPending = false
            returnHookToBasePosition()
            return
        }
        
        isHoldingScreen = false
        
        if touch.timestamp - touchStartTime <= tapDurationLimit {
            returnHookToBasePosition()
        } else {
            stoppedBaitPosition = hookSystem.baitPosition(in: self)
            isWaitingForFish = true
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isHoldingScreen = false
        isWaitingForFish = false
        isReturnTapPending = false
        stoppedBaitPosition = nil
        catchTargetSystem.resetCatchSession()
        isHookCastActive = false
    }
    
    private func updateCameraFall(deltaTime: TimeInterval) {
        guard isHoldingScreen else {
            return
        }
        
        moveCamera(by: -cameraFallSpeed * CGFloat(deltaTime))
        hookSystem.moveTowardCenter(deltaTime: deltaTime)
    }
    
    private func returnHookToBasePosition() {
        isHoldingScreen = false
        isWaitingForFish = false
        stoppedBaitPosition = nil
        catchTargetSystem.resetCatchSession()
        playReelingSound(duration: hookSystem.resetToTopDuration)
        hookSystem.playTapAnimation()
        hookSystem.resetToTop()
        returnCameraToBasePosition { [weak self] in
            self?.isHookCastActive = false
        }
    }
    
    private func returnCameraToBasePosition(
        completion: (() -> Void)? = nil
    ) {
        let basePosition = CGPoint(x: 0, y: seaTop - size.height / 2)
        sceneCamera.removeAction(forKey: "returnToBase")
        sceneCamera.run(
            SKAction.sequence([
                SKAction.move(
                    to: basePosition,
                    duration: 0.6
                ),
                SKAction.run {
                    completion?()
                }
            ]),
            withKey: "returnToBase"
        )
    }
    
    private func updateCatchTarget(currentTime: TimeInterval) {
        guard
            isHookCastActive,
            isHoldingScreen == false,
            isWaitingForFish,
            let baitPosition = stoppedBaitPosition
        else {
            return
        }
        
        if catchTargetSystem.tryCatchFish(
            from: fishEntities,
            hookPosition: baitPosition,
            hookLayer: layer(for: baitPosition.y),
            currentTime: currentTime,
            onHooked: { [weak self] caughtFish in
                guard let self else { return }
                self.playFishCaughtSound(duration: 0.2)
                self.playHaptic()
                self.isWaitingForFish = false
                self.playReelingSound(duration: self.hookSystem.resetToTopDuration)
                self.hookSystem.attachCaughtFish(
                    caughtFish,
                    in: self
                )
                self.returnCameraToBasePosition { [weak self] in
                    guard let self else { return }
                    self.hookSystem.removeAttachedFish()
                    self.catchTargetSystem.resetCatchSession()
                    self.stoppedBaitPosition = nil
                    self.isHookCastActive = false
                }
            },
            onFailed: { [weak self] _ in
                self?.isWaitingForFish = true
            }
        ) != nil {
            isWaitingForFish = false
        }
    }
    
    private func playHaptic(){
        heavyImpactFeedBack.impactOccurred()
        heavyImpactFeedBack.prepare()
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
    
    private func drawLayerDivider(at yPosition: CGFloat) {
        let line = SKShapeNode(rectOf: CGSize(width: size.width, height: 2))
        line.position = CGPoint(x: 0, y: yPosition)
        line.fillColor = .white
        line.strokeColor = .white
        line.alpha = 0.5
        addChild(line)
    }
}
