//
//  GameScene.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//

import SpriteKit
import GameplayKit

class FishingScene: SKScene {
    private var entities = [GKEntity]()
    
    private var wheelEntity: GKEntity!
    
    private let mainCamera = SKCameraNode()
    
    private var elapsedTime = 0.0
    
    var cameraSystem = GKComponentSystem(componentClass: CameraSystem.self)
    private var reelingSystem = GKComponentSystem(componentClass: ReelingSystem.self)
    private var reelingVisualSystem = GKComponentSystem(componentClass: ReelingVisualSystem.self)
    
    var success: Bool = false
    
    var lastUpdateTime: TimeInterval = 0

    override func didMove(to view: SKView) {
            setupReeling()
            setupCamera()
        }
    
    private func setupCamera() {
        addChild(mainCamera)
        mainCamera.position = CGPoint(x: 0, y: -320)
        self.camera = mainCamera
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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
                }
                
            } else {
                print("Miss! Fish pulling away. Progress: \(variables.catchProgress)")
                
        
                
                if variables.catchProgress <= 0.0 {
                    print("Fish escaped back to 0 progress...")
                }
            }
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

    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 { lastUpdateTime = currentTime }
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        elapsedTime += deltaTime
        
        if(success == true){
            if(elapsedTime >= 0.5 || mainCamera.position.y >= 740){
                success = false
                elapsedTime = 0
            }else{
                mainCamera.position.y += 5.0
                
            }
            
        }
        
        
        reelingSystem.update(deltaTime: deltaTime)
        reelingVisualSystem.update(deltaTime: deltaTime)
    }
}
