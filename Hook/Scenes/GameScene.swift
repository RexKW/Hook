//
//  GameScene.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//

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
    private let mainCamera = SKCameraNode()
    
    /// Systems
    let movementSystem = GKComponentSystem(componentClass: MovementSystem.self)
    var cameraSystem = GKComponentSystem(componentClass: CameraSystem.self)
    var stateSystem = GKComponentSystem(componentClass: GameStateSystem.self)
    private var reelingSystem = GKComponentSystem(componentClass: ReelingSystem.self)
    private var reelingVisualSystem = GKComponentSystem(componentClass: ReelingVisualSystem.self)
    
    /// Nodes dari .sks
    private var characterNode: SKSpriteNode!
    private var hookNode: SKSpriteNode!
    private var lineNode: SKSpriteNode!
    
    /// Nodes Indikator Progression (Clean: indikatorIsi dihapus karena tidak terpakai)
    private var indikatorBg: SKSpriteNode!
    private var indikatorPointer: SKSpriteNode!
    private var zonaIcon: SKSpriteNode!
     
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
    
    override func didMove(to view: SKView) {
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
        
        let hook = HookEntity(node: hookNode, camera: self.camera!)
        hookEntity = hook
        
        setupHook()
        
        // Membangun HUD Indikator dari Aset secara dinamis
        setupProgressionIndicator(view: view)
    }
    
    func setupHook() {
        if let node = childNode(withName: "Hook") as? SKSpriteNode {
            let entity = HookEntity(node: node, camera: mainCamera)
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
    
    // Indikator UI
    private func setupProgressionIndicator(view: SKView) {
        indikatorBg = SKSpriteNode(imageNamed: "Progression")
        indikatorPointer = SKSpriteNode(imageNamed: "Indicator")
        zonaIcon = SKSpriteNode(texture: teksturBoatLvl1)
        
        // Clean: Memperbaiki nama variabel menggunakan camelCase standar Swift
        let longProgression: CGFloat = 1200.0
        let wideProgression: CGFloat = 70.0
        
        indikatorBg.size = CGSize(width: wideProgression, height: longProgression)
        indikatorPointer.size = CGSize(width: 100, height: 50)
        
        indikatorBg.zPosition = 1900
        indikatorPointer.zPosition = 2000
        zonaIcon.zPosition = 2100
        
        [indikatorBg, indikatorPointer, zonaIcon].forEach { node in
            node.texture?.filteringMode = .nearest
            mainCamera.addChild(node)
        }
        
        // Konfigurasi letak dinamis mepet ke kiri layar
        let batasKiriAman = view.safeAreaInsets.left
        let ukuranScene = self.size
        
        let posisiX = -(ukuranScene.width / 2) + max(70, batasKiriAman + 150)
        let posisiY: CGFloat = 40
        
        indikatorBg.position = CGPoint(x: posisiX, y: posisiY)
        
        zonaIcon.size = CGSize(width: 160, height: 160)
        zonaIcon.position = CGPoint(x: posisiX + 10, y: posisiY + (indikatorBg.size.height / 2) + 40)

        [indikatorBg, indikatorPointer, zonaIcon].forEach { $0.isHidden = true }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Hold!")
        
        guard let entity = hookEntity,
            let input = hookEntity?.component(ofType: InputComponent.self),
            let stateComp = entity.component(ofType: StateComponent.self) else {
            print("❌ Error: InputComponent tidak ditemukan di Entity!")
            return
        }
        
        input.handleTouchBegan()
        print("isHolding sekarang: \(input.isHolding)")
        
        let currentState = stateComp.stateMachine.currentState
                
        if currentState is IdleState {
            print("casting")
            stateComp.stateMachine.enter(CastingState.self)
        }
        
        if currentState is WaitingState {
            if input.isTapped {
                setupReeling()
                stateComp.stateMachine.enter(ReelingState.self)
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
                logic.randomizeTarget()
                variables.rotationSpeed += 0.2
                elapsedTime = 0
                
                if hookNode.position.y >= -940 {
                    print("FISH CAUGHT! You win!")
                    variables.rotationSpeed = 0
                    
                    if let rodaPancing = mainCamera.childNode(withName: "Wheel") {
                        rodaPancing.removeFromParent()
                    }
                    
                    // Clean: Menghapus data instansiasi entity dari array RAM memory agar tidak leak
                    if let index = entities.firstIndex(of: wheel) {
                        entities.remove(at: index)
                    }
                    
                    stateComp.stateMachine.enter(IdleState.self)
                }
                
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
            hookNode.position = CGPoint(x: rodTipPosition.x - 5 , y: rodTipPosition.y - 20)
        } else {
            if let movement = entity.component(ofType: MovementSystem.self) {
                movement.update(deltaTime: dt, rodTip: rodTipPosition)
            }
        }
        
        if success == true {
            if elapsedTime >= 0.5 || mainCamera.position.y >= 740 {
                success = false
                elapsedTime = 0
            } else {
                hookNode.position.y += 10.0
            }
        }

        stateSystem.update(deltaTime: dt)
        cameraSystem.update(deltaTime: dt)

        updateLineVisual()
        reelingSystem.update(deltaTime: dt)
        reelingVisualSystem.update(deltaTime: dt)
        movementSystem.update(deltaTime: dt)

        entity.component(ofType: InputComponent.self)?.isTapped = false
        
        updateMekanikIndikator()
    }
    
    func updateMekanikIndikator() {
        guard let entity = hookEntity,
              let stateComp = entity.component(ofType: StateComponent.self) else { return }
        
        let currentState = stateComp.stateMachine.currentState
        
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
}
