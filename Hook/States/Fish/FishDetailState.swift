//
//  FishData.swift
//  Hook
//
//  Created by Rex Kenny Wirasantoso on 11/05/26.
//

import Foundation

struct FishDetailState: Identifiable {
    let id = UUID()
    let imageName: String          // color asset name
    let silhouetteName: String     // locked silhouette asset name
    let name: String
    let description: String
    var bestWeight: String         // pull/override from save data
    var timesCaught: Int           // pull/override from save data
    var isUnlocked: Bool
    var displayScale: CGFloat = 1.0 // each fish size multiplier (default 1.0)
}

enum FishDatabase {
    static let all: [FishDetailState] = [
        // 1. Tuna Fish
        FishDetailState(
            imageName: "TunaFishColor",
            silhouetteName: "TunaFish",
            name: "Tuna Fish",
            description: "Tuna are actually built different because they literally rejected being cold blooded",
            bestWeight: "2 Kg", timesCaught: 8, isUnlocked: false,
            displayScale: 1
            
        ),
        // 2. Marlin Fish
        FishDetailState(
            imageName: "BlueMarlinFishColor",
            silhouetteName: "MarlinFish",
            name: "Marlin Fish",
            description: "Marlins are basically the ocean’s tryhard gamers pulling up with the built-in RGB lighting",
            bestWeight: "0,2 Kg", timesCaught: 1, isUnlocked: false,
            displayScale: 2
        ),
        // 3. Mackerel Fish
        FishDetailState(
            imageName: "MackerelFishColor",
            silhouetteName: "MackerelFish",
            name: "Mackerel Fish",
            description: "The ultimate ocean tryhards with absolutely zero chill",
            bestWeight: "4 Kg", timesCaught: 4, isUnlocked: false,
            displayScale: 1.2
        ),
        // 4. Lion Fish
        FishDetailState(
            imageName: "LionFishColor",
            silhouetteName: "LionFish",
            name: "Lion Fish",
            description: "Lionfish is the ocean’s biggest menace and they are literally built toxic",
            bestWeight: "0,3 Kg", timesCaught: 2, isUnlocked: false,
            displayScale: 0.8
        ),
        // 5. Ruby Snapper
        FishDetailState(
            imageName: "RubySnapperColor",
            silhouetteName: "RubySnapper",
            name: "Ruby Snapper",
            description: "I’m not staring, my eyes are just built like this because the water pressure is too real, fr fr!",
            bestWeight: "20 Kg", timesCaught: 12, isUnlocked: false,
            displayScale: 1.2
        ),
        // 6. Hatchet Fish
        FishDetailState(
            imageName: "HatchetFishColor",
            silhouetteName: "HatchetFish",
            name: "Hatchet Fish",
            description: "Imagine flexing an actual invisibility cloak just so the ops can't catch you lacking from below… fr fr!",
            bestWeight: "0 Kg", timesCaught: 0, isUnlocked: false,
            displayScale: 1.2
        ),
        // 7. Oar Fish
        FishDetailState(
            imageName: "OarFishColor",
            silhouetteName: "OarFish",
            name: "Oar Fish",
            description: "Oarfish have negative rizz and are lowkey the most socially awkward creatures to ever exist",
            bestWeight: "0 Kg", timesCaught: 0, isUnlocked: false,
            displayScale: 0.9
        ),
        // 8. Bluenose Warehou
        FishDetailState(
            imageName: "BlueNoseWarehouColor",
            silhouetteName: "BluenoseWarehouFish",
            name: "Bluenose Warehou",
            description: "Bro is really out here living for like 70 years straight, just casually munching on squid and avoiding surface drama",
            bestWeight: "0 Kg", timesCaught: 0, isUnlocked: false,
            displayScale: 1
        ),
        // 9. Angler Fish
        FishDetailState(
            imageName: "AnglerFishColor",
            silhouetteName: "AnglerFish",
            name: "Angler Fish",
            description: "Bro is out here in the absolute midnight zone, sniffing around for a giant goth gf with a glowing headlamp",
            bestWeight: "0 Kg", timesCaught: 0, isUnlocked: false,
            displayScale: 1.4
        ),
        // 10. Ratail Fish
        FishDetailState(
            imageName: "RatailFishColor",
            silhouetteName: "RatailFish",
            name: "Ratail Fish",
            description: "Imagine having zero visual rizz so you just start beatboxing in the dark hoping a girl notices you",
            bestWeight: "0 Kg", timesCaught: 0, isUnlocked: false,
            displayScale: 1.2
        ),
        // 11. Fangtooth Fish
        FishDetailState(
            imageName: "FangToothColor",
            silhouetteName: "FangToothFish",
            name: "Fangtooth Fish",
            description: "Fangtooth is literally out here looking like a whole sleep paralysis demon, but bro is only six inches tall",
            bestWeight: "0 Kg", timesCaught: 0, isUnlocked: false,
            displayScale: 1.4
        ),
        // 12. Giant Squid
        FishDetailState(
            imageName: "GiantSquidColor",
            silhouetteName: "GiantSquid",
            name: "Giant Squid",
            description: "Squid actually built different. Lurking just waiting to catch ops lacking in 4K",
            bestWeight: "0 Kg", timesCaught: 0, isUnlocked: false,
            displayScale: 1
        )
    ]
}
