//
//  Marker.swift
//  LeapFrog
//
//  Created by Casey Ross on 7/15/16.
//  Copyright © 2016 Case Development. All rights reserved.
//

import UIKit
import SpriteKit

class Marker: SKSpriteNode {
    
    static let thinkingTexture = SKTexture(imageNamed: "thinking")
    static let whiteTexture = SKTexture(imageNamed: "orangeFrog")
    static let blackTexture = SKTexture(imageNamed: "greenFrog")
    
    func setPlayer(_ player: MarkerColor) {
        if player == .white {
            texture = Marker.whiteTexture
        }else if player == .black {
            texture = Marker.blackTexture
        }else if player == .choice {
            texture = Marker.thinkingTexture
        }
    }
    
    var row = 0
    var col = 0

}
