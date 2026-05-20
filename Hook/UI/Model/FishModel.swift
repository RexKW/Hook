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
    var weightKg: Double
    var imageHeight: CGFloat?
    
    init(name:String, imageName:String, weightKg:Double, imageHeight:CGFloat? = nil){
        self.name = name
        self.imageName = imageName
        self.weightKg = weightKg
        self.imageHeight = imageHeight
    }
}
