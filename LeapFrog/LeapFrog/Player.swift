//
//  Player.swift
//  LeapFrog
//
//  Created by Casey Ross on 7/15/16.
//  Copyright © 2016 Case Development. All rights reserved.
//

import UIKit
import GameplayKit

class Player: NSObject, GKGameModelPlayer {
    
    var playerId: Int
    
    static let allPlayers = [Player(marker: .black), Player(marker: .white)]
    
    var markerColor: MarkerColor
    
    init(marker: MarkerColor){
    
        markerColor = marker
        self.playerId = markerColor.rawValue
    }
    
    var opponent: Player {
    
        if markerColor == .black {
            return Player.allPlayers[1]
        }else{
            return Player.allPlayers[0]
        }
    }

}
