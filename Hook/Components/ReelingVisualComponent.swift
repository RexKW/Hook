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
    
    private let radius: CGFloat = 50.0
    
    override init() {
        // 1. Draw the smaller wheel
        wheelNode = SKShapeNode(circleOfRadius: radius)
        wheelNode.strokeColor = .darkGray
        wheelNode.lineWidth = 8
        rootNode.addChild(wheelNode)
        // 2. Draw the indicator
        let indicatorPath = CGMutablePath()
        indicatorPath.move(to: .zero)
        indicatorPath.addLine(to: CGPoint(x: radius + 8, y: 0))
        indicatorNode = SKShapeNode(path: indicatorPath)
        indicatorNode.strokeColor = .red
        indicatorNode.lineWidth = 4
        rootNode.addChild(indicatorNode)
        
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
        func drawTargetZone(startAngle: CGFloat, width: CGFloat) {
            targetZoneNode?.removeFromParent()
            
            let path = CGMutablePath()
            path.addArc(center: .zero, radius: radius, startAngle: startAngle, endAngle: startAngle + width, clockwise: false)
            
            targetZoneNode = SKShapeNode(path: path)
            targetZoneNode?.strokeColor = .green
            targetZoneNode?.lineWidth = 8
            
            if let targetNode = targetZoneNode {
                rootNode.addChild(targetNode)
            }
        }
}
