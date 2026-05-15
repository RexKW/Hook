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
    
    override func didMove(to view: SKView) {
    
        characterNode = childNode(withName: "Character2") as? SKSpriteNode
        hookNode = childNode(withName: "Hook") as? SKSpriteNode
        lineNode = childNode(withName: "Joran") as? SKSpriteNode
        
        lineNode.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        
        guard characterNode != nil, hookNode != nil, lineNode != nil else {
            print("❌ ERROR: Salah satu Node tidak ditemukan. Cek nama di .sks!")
            return
        }
        
        [characterNode, hookNode, lineNode].forEach { $0?.texture?.filteringMode = .nearest }
        
        guard let sceneCamera = self.camera else {
            print("❌ Peringatan: Kamera belum diatur di .sks!")
            return
        }
        
        let hook = HookEntity(node: hookNode, camera: sceneCamera)
        hookEntity = hook
        
        if let moveComponent = hook.component(ofType: MovementComponent.self) {
            movementSystem.addComponent(moveComponent)
        }
        
        if let cameraComponent = hook.component(ofType: CameraComponent.self) {
            cameraSystem.addComponent(cameraComponent)
        }
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
}













//import SpriteKit
//import GameplayKit
//
//class GameScene: SKScene {
//    
//    private var label : SKLabelNode?
//    private var spinnyNode : SKShapeNode?
//    
//    override func didMove(to view: SKView) {
//        
//        // Get label node from scene and store it for use later
//        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
//        if let label = self.label {
//            label.alpha = 0.0
//            label.run(SKAction.fadeIn(withDuration: 2.0))
//        }
//        
//        // Create shape node to use during mouse interaction
//        let w = (self.size.width + self.size.height) * 0.05
//        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
//        
//        if let spinnyNode = self.spinnyNode {
//            spinnyNode.lineWidth = 2.5
//            
//            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
//            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
//                                              SKAction.fadeOut(withDuration: 0.5),
//                                              SKAction.removeFromParent()]))
//        }
//    }
//    
//    
//    func touchDown(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.green
//            self.addChild(n)
//        }
//    }
//    
//    func touchMoved(toPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.blue
//            self.addChild(n)
//        }
//    }
//    
//    func touchUp(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.red
//            self.addChild(n)
//        }
//    }
//    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let label = self.label {
//            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
//        }
//        
//        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
//    }
//    
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
//    }
//    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
//    }
//    
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
//    }
//    
//    
//    override func update(_ currentTime: TimeInterval) {
//        // Called before each frame is rendered
//    }
//}
