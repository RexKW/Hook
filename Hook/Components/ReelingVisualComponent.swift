//
//  ReelingVisualComponent.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 13/05/26.
//

import GameplayKit

class ReelingVisualComponent: GKComponent {
    let rootNode = SKNode()
    
    // Wheel nodes
    private let wheelNode: SKShapeNode
    private var targetZoneNode: SKShapeNode?
    let indicatorNode: SKShapeNode
    
    // Progress Bar nodes
//    private let progressBarBackground: SKShapeNode
//    let progressBarFill: SKSpriteNode
    let maxBarWidth: CGFloat = 192.0
    
    private let radius: CGFloat = 80
    
    override init() {
        // 1. Draw the smaller wheel
        wheelNode = SKShapeNode(circleOfRadius: radius)
        wheelNode.strokeColor = .darkGray
        wheelNode.lineWidth = 16
        rootNode.addChild(wheelNode)
        // 2. Draw the indicator (Green Triangle, Pointing Inwards)
                let indicatorPath = CGMutablePath()
                // Tip of the triangle, pointing inwards towards the center
                indicatorPath.move(to: CGPoint(x: radius - 5 + 30, y: 0))
                // Top corner of the triangle base (outside the circle)
                indicatorPath.addLine(to: CGPoint(x: radius + 15 + 30, y: 8))
                // Bottom corner of the triangle base (outside the circle)
                indicatorPath.addLine(to: CGPoint(x: radius + 15 + 30, y: -8))
                indicatorPath.closeSubpath() // Closes the shape to make a proper triangle
                
                indicatorNode = SKShapeNode(path: indicatorPath)
                indicatorNode.fillColor = .green
                indicatorNode.strokeColor = .green
                indicatorNode.lineWidth = 1
                rootNode.addChild(indicatorNode)
                
                rootNode.zPosition = 10
//        // 3. Draw Progress Bar Background (Positioned below the wheel)
//        progressBarBackground = SKShapeNode(rectOf: CGSize(width: 200, height: 20), cornerRadius: 5)
//        progressBarBackground.strokeColor = .white
//        progressBarBackground.position = CGPoint(x: 0, y: -90)
//        rootNode.addChild(progressBarBackground)
//        
//        // 4. Draw Progress Bar Fill
//        // We use a SpriteNode anchored to the left so it scales left-to-right naturally
//        progressBarFill = SKSpriteNode(color: .cyan, size: CGSize(width: 0, height: 14))
//        progressBarFill.anchorPoint = CGPoint(x: 0, y: 0.5)
//        progressBarFill.position = CGPoint(x: -96, y: -90) // Set to the left edge of the background
//        rootNode.addChild(progressBarFill)
        
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Helper function for the system to call
    
    func setupTargetZoneIfNeeded(width: CGFloat){
        // If the node already exists, we don't need to recreate it.
            guard targetZoneNode == nil else { return }
                
                let path = CGMutablePath()
                // Draw the arc starting from 0 up to the target width
                path.addArc(center: .zero, radius: radius, startAngle: 0, endAngle: width, clockwise: false)
                
                let node = SKShapeNode(path: path)
                node.strokeColor = .green
                node.lineWidth = 16
                
                rootNode.addChild(node)
                targetZoneNode = node
    }
    func updateTargetZoneRotation(startAngle: CGFloat) {
            targetZoneNode?.zRotation = startAngle
        }
    
    func triggerFailureEffect() {
        let originalColor = wheelNode.strokeColor
        guard let originalTargetColor = targetZoneNode?.strokeColor else { return }
        
        let turnRed = SKAction.run { self.wheelNode.strokeColor = UIColor(red: 0.6, green: 0.0, blue: 0.0, alpha: 1.0); self.targetZoneNode?.strokeColor = .red }
        let waitDelay = SKAction.wait(forDuration: 0.3)
        let revertColor = SKAction.run { self.wheelNode.strokeColor = originalColor; self.targetZoneNode?.strokeColor = originalTargetColor }
        
        let colorSequence = SKAction.sequence([turnRed, waitDelay, revertColor])
        
        
        let moveLeft = SKAction.moveBy(x: -8, y: 0, duration: 0.05)
        let moveRight = SKAction.moveBy(x: 16, y: 0, duration: 0.1)
        let moveCenter = SKAction.moveBy(x: -8, y: 0, duration: 0.05)
        
        let singleShake = SKAction.sequence([moveLeft, moveRight, moveCenter])
        let shakeSequence = SKAction.repeat(singleShake, count: 2)
        
        let failureEffect = SKAction.group([colorSequence, shakeSequence])
        
        
        wheelNode.removeAction(forKey: "failureEffect")
        targetZoneNode?.removeAction(forKey: "failureEffect")
        wheelNode.run(failureEffect, withKey: "failureEffect")
        targetZoneNode?.run(failureEffect, withKey: "failureEffect")
    }
}
