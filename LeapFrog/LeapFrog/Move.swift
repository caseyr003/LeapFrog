//
//  Move.swift
//  LeapFrog
//
//  Created by Casey Ross on 7/15/16.
//  Copyright © 2016 Case Development. All rights reserved.
//

import UIKit
import GameplayKit

class Move: NSObject, GKGameModelUpdate {
    
    var row: Int
    var col: Int
    
    var value = 0
    
    init(row: Int, col: Int){
        self.row = row
        self.col = col
    }

}
