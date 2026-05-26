//
//  MovementComponent.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//

import GameplayKit

class MovementComponent: GKComponent {
//    let dropSpeed: CGFloat = 800
//    let reelSpeed: CGFloat = 1000
    
    func dropSpeed(for boatLevel: Int) -> CGFloat {
            switch boatLevel {
            case 1:
                return 400.0
            case 2:
                return 600.0
            case 3:
                return 1000.0
            default:
                return 400.0
            }
        }
    
    func reelSpeed(for boatLevel: Int) -> CGFloat {
            switch boatLevel {
            case 1:
                return 800.0
            case 2:
                return 1000.0
            case 3:
                return 1500.0
            default:
                return 800.0
            }
        }
}
