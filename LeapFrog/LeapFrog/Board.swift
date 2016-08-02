//
//  Board.swift
//  LeapFrog
//
//  Created by Casey Ross on 7/15/16.
//  Copyright © 2016 Case Development. All rights reserved.
//

import UIKit
import GameplayKit

class Board: NSObject, GKGameModel {
    
    var players: [GKGameModelPlayer]? {
        return Player.allPlayers
    }
    
    var activePlayer: GKGameModelPlayer? {
        return currentPlayer
    }

    static let size = 8
    
    static let moves = [Move(row: -1, col: -1), Move(row: 0, col: -1), Move(row: 1, col: -1), Move(row: -1, col: 0), Move(row: 1, col: 0), Move(row: -1, col: 1), Move(row: 0, col: 1), Move(row: 1, col: 1)]
    
    var currentPlayer = Player.allPlayers[0]
    
    var rows = [[MarkerColor]]()
    
    func canMoveIn(row: Int, col: Int) -> Bool {
        
        if !isInBounds(row: row, col: col) {return false}
        
        let marker = rows[row][col]
        if marker != .empty {return false}
        
        for move in Board.moves {
            
            var passedOpponenet = false
            var currentRow = row
            var currentCol = col

            for _ in 0 ..< Board.size {
                
                currentRow += move.row
                currentCol += move.col
                
                guard isInBounds(row: currentRow, col: currentCol) else { break }
                
                let marker = rows[currentRow][currentCol]
                
                if (marker == currentPlayer.opponent.markerColor){
                
                    passedOpponenet = true
                    
                }else if marker == currentPlayer.markerColor && passedOpponenet {
                    return true
                }else{
                
                    break
                }
            
            }
        }
    
        return false
    }
    
    func isInBounds(row: Int, col: Int) -> Bool {
        
        if row < 0 {return false}
        if col < 0 {return false}
        if row >= Board.size {return false}
        if col >= Board.size {return false}
    
        return true
    }
    
    func makeMove(player: Player, row: Int, col: Int) -> [Move] {
    
        var didCapture = [Move]()
        
        rows[row][col] = player.markerColor
        
        didCapture.append(Move(row: row, col: col))
        
        for move in Board.moves {
            
            var mightCapture = [Move]()
            var currentRow = row
            var currentCol = col
            
            for _ in 0 ..< Board.size {
            
                currentRow += move.row
                currentCol += move.col
                
                guard isInBounds(row: currentRow, col: currentCol) else { break }
                
                let marker = rows[currentRow][currentCol]
                
                if marker == player.opponent.markerColor {
                
                    mightCapture.append(Move(row: currentRow, col: currentCol))
                }else if marker == player.markerColor {
                    
                    didCapture.append(contentsOf: mightCapture)
                    
                    mightCapture.forEach{
                    
                        rows[$0.row][$0.col] = player.markerColor
                        
                    }
                    
                    break
                
                }else{
                
                    break
                
                }
            
            }
            
        }
        
        return didCapture
    
    }
    
    func getScores() -> (white: Int, black: Int) {
    
        var white = 0
        var black = 0
        
        rows.forEach {
            
            $0.forEach{
                
                if $0 == .white {
                    
                    white += 1
                
                }else if $0 == .black {
                
                    black += 1
                    
                }
            }
        }
    
        return (white, black)
    
    }
    
    func isWin(for player: GKGameModelPlayer) -> Bool{
    
        guard let playerObject = player as? Player else { return false }
        
        let scores = getScores()
        
        if playerObject.markerColor == .black {
        
            return scores.black > scores.white + 10
        
        }else{
        
            return scores.white > scores.black + 10
            
        }
    }
    
    
    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
    
        guard let playerObject = player as? Player else { return nil }
        
        if isWin(for: playerObject) || isWin(for: playerObject.opponent) {
        
            return nil
        }
        
        var moves = [Move]()
        
        for row in 0 ..< Board.size {
        
            for col in 0 ..< Board.size {
            
                if canMoveIn(row: row, col: col){
                
                    moves.append(Move(row: row, col: col))
                
                }
            
            }
            
        }
        return moves
    
    }
    
    
    func apply(_ gameModelUpdate: GKGameModelUpdate) {
    
        guard let move = gameModelUpdate as? Move else { return }
        
        _ = makeMove(player: currentPlayer, row: move.row, col: move.col)
        
        currentPlayer = currentPlayer.opponent
    
    }
    
    func setGameModel(_ gameModel: GKGameModel) {
    
        guard let board = gameModel as? Board else { return }
        
        currentPlayer = board.currentPlayer
        
        rows = board.rows
    }
    
    func copy(with zone: NSZone? = nil) -> AnyObject {
    
        let copy = Board()
        
        copy.setGameModel(self)
        
        return copy
        
    }
}
