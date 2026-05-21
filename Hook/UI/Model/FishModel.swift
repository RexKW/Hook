//
//  FishModel.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 20/05/26.
//

import Foundation
import SwiftData

@Model
class FishModel{
    var id = UUID()
    var name: String
    var imageName: String
    var weightKg: CGFloat
    var imageHeight: CGFloat?
    
    var formattedWeight: String {
        let formatted = String(format: "%.1f", weightKg).replacingOccurrences(of: ".", with: ",")
        return "\(formatted) kg"
    }
    
    init(imageName:String, weightKg:CGFloat){
        switch imageName {
            case "Tuna fish", "Tuna Fish":
                self.name = "Tuna Fish"
                self.imageName = "TunaFishColor"
                self.imageHeight = 320

            case "Mackerel":
                self.name = "Mackerel Fish"
                self.imageName = "MackerelFishColor"
                self.imageHeight = 170

            case "Lion Fish":
                self.name = "Lion Fish"
                self.imageName = "LionFishColor"
                self.imageHeight = 200

            case "Marlin":
                self.name = "Marlin Fish"
                self.imageName = "BlueMarlinFishColor"
                self.imageHeight = 200

            case "Ruby snapper", "Ruby Snapper":
                self.name = "Ruby Snapper"
                self.imageName = "RubySnapperColor"
                self.imageHeight = 150

            case "Hatchet Fish":
                self.name = "Hatchet Fish"
                self.imageName = "HatchetFishColor"
                self.imageHeight = 150

            case "Oar Fish":
                self.name = "Oar Fish"
                self.imageName = "OarFishColor"
                self.imageHeight = 110

            case "Bluenose warehou Fish":
                self.name = "Bluenose Warehou"
                self.imageName = "BlueNoseWarehouColor"
                self.imageHeight = 120

            case "anglerfish-new1":
                self.name = "Angler Fish"
                self.imageName = "AnglerFishColor"
                self.imageHeight = 200

            case "Ratail fish":
                self.name = "Ratail Fish"
                self.imageName = "RatailFishColor"
                self.imageHeight = 160

            case "fangtooth1-export 1":
                self.name = "Fangtooth Fish"
                self.imageName = "FangToothColor"
                self.imageHeight = 200

            case "Giant Squid":
                self.name = "Giant Squid"
                self.imageName = "GiantSquidColor"
                self.imageHeight = 170
                
            default:
                self.name = "Unknown"
                self.imageName = imageName // Fallback to the original sprite
                self.imageHeight = 150
        }
        
        self.weightKg = weightKg
        
    }
}
