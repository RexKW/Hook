//
//  GameScene.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//


import SpriteKit
import GameplayKit

class GameScene: SKScene {
    ///Entities
    private var entities = [GKEntity]()
    private var hookEntity: HookEntity?
    private var wheelEntity: GKEntity!
    private let mainCamera = SKCameraNode()
    
    
    ///Systems
    let movementSystem = GKComponentSystem(componentClass: MovementSystem.self)
    var cameraSystem = GKComponentSystem(componentClass: CameraSystem.self)
    private var reelingSystem = GKComponentSystem(componentClass: ReelingSystem.self)
    private var reelingVisualSystem = GKComponentSystem(componentClass: ReelingVisualSystem.self)
    
    
    ///Nodes
    private var characterNode: SKSpriteNode!
    private var hookNode: SKSpriteNode!
    private var lineNode: SKSpriteNode!
    
    
    
    ///Variables
    var rodTipPosition: CGPoint {
        return CGPoint(x: characterNode.position.x + 215, y: characterNode.position.y + 20)
    }
    var success: Bool = false
    var lastUpdateTime: TimeInterval = 0
    var possibleClouds = ["Cloud-1","Cloud-2","Cloud-3"]
    var gameTimer:Timer!
    
    var initialClouds:Bool = true
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
        
        [characterNode, hookNode, lineNode].forEach { $0?.texture?.filteringMode = .nearest }
        
        setupCamera()
        
        let hook = HookEntity(node: hookNode, camera: self.camera!)
        hookEntity = hook
    }
    
    private func setupCamera() {
        addChild(mainCamera)
        self.camera = mainCamera
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Hold!")
        
        guard let input = hookEntity?.component(ofType: InputComponent.self) else {
            print("❌ Error: InputComponent tidak ditemukan di Entity!")
            return
        }
        
        input.handleTouchBegan()
        print("isHolding sekarang: \(input.isHolding)")
        
        if let state = hookEntity?.component(ofType: StateComponent.self) {
            print("Current State: \(state.currentState)")
            if state.currentState == .idle {
                hookEntity?.stateMachine?.enter(CastingState.self)
            }
        }
        guard let entity = hookEntity else { return }
        let state = entity.component(ofType: StateComponent.self)?.currentState
        
        if state == .reeling {
            guard let logic = wheelEntity.component(ofType: ReelingSystem.self) else { return }
            guard let variables = wheelEntity.component(ofType: ReelingComponent.self) else { return }
            
            // If the game is already over, don't do anything
            if variables.catchProgress >= 1.0 {
                print("Fish already caught! Resetting...")
                variables.catchProgress = 0.0
                return
            }
            
            success = logic.attemptReel()
            
            if success {
                print("Hit! Progress: \(variables.catchProgress)")
                logic.randomizeTarget()
                variables.rotationSpeed += 0.2 // Speed up slightly on success
                elapsedTime = 0
                
                if mainCamera.position.y >= 740.0 {
                    print("FISH CAUGHT! You win!")
                    // TODO: Show win screen, trigger animations, etc.
                    variables.rotationSpeed = 0 // Stop the wheel
                    mainCamera.removeAllChildren()
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

        guard let entity = hookEntity else { return }
        let state = entity.component(ofType: StateComponent.self)?.currentState
        
        if state == .reeling{
            setupReeling()
        }

        if state == .idle {
            hookNode.position = rodTipPosition
        } else {
            movementSystem.update(deltaTime: dt)
        }

        entity.stateMachine?.update(deltaTime: dt)
        cameraSystem.update(deltaTime: dt)

        updateLineVisual()

        entity.component(ofType: InputComponent.self)?.isTapped = false
    }
    
    
    func updateLineVisual() {
        let start = rodTipPosition
        let end = hookNode.position
        
        lineNode.position = start
        
        let distance = start.y - end.y
        let textureHeight = lineNode.texture?.size().height ?? 1.0
        
        lineNode.yScale = max(0.01, distance / textureHeight)
        
        lineNode.zPosition = 10
        hookNode.zPosition = 12
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
        }else{
            if randomCloudDirection {
                    cloud.position = CGPoint(x: rightEdge, y: positionY)
                } else {
                    cloud.position = CGPoint(x: leftEdge, y: positionY)
                }
        }
        
        
        
        
        self.addChild(cloud)
        
        let animationDuration:TimeInterval = 60
        
        var actionArray = [SKAction]()
        
        
        
        if randomCloudDirection {
                actionArray.append(SKAction.move(to: CGPoint(x: leftEdge, y: positionY), duration: animationDuration))
            } else {
                actionArray.append(SKAction.move(to: CGPoint(x: rightEdge, y: positionY), duration: animationDuration))
            }
        
        actionArray.append(SKAction.removeFromParent())
        
        cloud.run(SKAction.sequence(actionArray))
        
    
    }

    func setupReeling(){
        if let node = childNode(withName: "//Wheel") as? SKSpriteNode {
                
                // 2. Create the Entity
                self.wheelEntity = WheelEntity(node: node)
                self.entities.append(wheelEntity) // Keep it in memory
                
                // 3. Register node with  systems
                reelingSystem.addComponent(foundIn: wheelEntity)
                reelingVisualSystem.addComponent(foundIn: wheelEntity)
            
                
                
                // 4. Attach custom drawn shapes to the SKS node
                if let visualComponent = wheelEntity.component(ofType: ReelingVisualComponent.self) {
                    // This adds all the circles and bars drew to the anchor point
                    visualComponent.rootNode.position = CGPoint(x: -100.0, y: 0.0)
                    mainCamera.addChild(visualComponent.rootNode)
                }
            
                
        }
    }
}
