//
//  GameScene.swift
//  LeapFrog
//
//  Created by Casey Ross on 7/15/16.
//  Copyright © 2016 Case Development. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var rows = [[Marker]]()
    
    var board: Board!
    
    var strategist: GKMonteCarloStrategist!
    
    
    override func didMove(to view: SKView) {
        
        let boardSize = Double((self.view?.bounds.width)! - 20)
        
        let background = SKSpriteNode(imageNamed: "bg")
        
        background.blendMode = .replace
        background.zPosition = 1
        background.size = CGSize(width: (self.view?.bounds.width)! + 50, height: (self.view?.bounds.height)! + 50)
        addChild(background)
        
        let gameBoard = SKSpriteNode(imageNamed: "board")
        
        gameBoard.name = "board"
        gameBoard.color = UIColor.clear()
        gameBoard.zPosition = 2
        let gameBoardOriginalSize = Double(gameBoard.size.width)
        let scalePercent = boardSize / gameBoardOriginalSize
        gameBoard.size = CGSize(width: boardSize, height: boardSize)
        addChild(gameBoard)
        
        board = Board()
        
        
        
        
        let markerSize = Double(scalePercent * 80)
        let offsetX = Double(-280 * scalePercent)
        let offsetY = Double(-280 * scalePercent)
        
        //   80 marker 8x80 = 640 board   
        // half board - half marker = 320 - 40 = -280
        // scale using screen size
        
        for row in 0 ..< Board.size {
        
            var colArray = [Marker]()
            
            for col in 0 ..< Board.size {
            
                let marker = Marker(color: UIColor.clear(), size: CGSize(width: markerSize, height: markerSize))
                
                marker.position = CGPoint(x: offsetX + (Double(col) * markerSize), y: offsetY + (Double(row) * markerSize))
                
                marker.row = row
                marker.col = col
                marker.zPosition = 3

                gameBoard.addChild(marker)
                
                colArray.append(marker)
            
            }
            
            board.rows.append([MarkerColor](repeating: .empty, count: Board.size))
            
            rows.append(colArray)
            
            strategist = GKMonteCarloStrategist()
            strategist.budget = 100
            strategist.explorationParameter = 1
            strategist.randomSource = GKRandomSource.sharedRandom()
            strategist.gameModel = board
        
        }
        
        rows[4][3].setPlayer(.white)
        rows[3][4].setPlayer(.white)
        rows[3][3].setPlayer(.black)
        rows[4][4].setPlayer(.black)
        
        board.rows[4][3] = .white
        board.rows[3][4] = .white
        board.rows[4][4] = .black
        board.rows[3][3] = .black
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        
        guard let gameBoard = childNode(withName: "board") else { return }
        
        let location = touch.location(in: gameBoard)
        
        let nodesAtPoint = nodes(at: location)
        
        let tappedMarkers = nodesAtPoint.filter { $0 is Marker}
        
        guard tappedMarkers.count > 0 else { return }
        
        let tappedMarker = tappedMarkers[0] as! Marker
        
        if board.canMoveIn(row: tappedMarker.row, col: tappedMarker.col) {
            print("Legal Move")
            self.rows[tappedMarker.row][tappedMarker.col].setPlayer(board.currentPlayer.markerColor)
            makeMove(row: tappedMarker.row, col: tappedMarker.col)
            if board.currentPlayer.markerColor == .white {
                makeAIMove()
            }
        }else{
            print("Illegal Move")
        }

    }
    
    func makeMove(row: Int, col: Int) {
    
        let captured = board.makeMove(player: board.currentPlayer, row: row, col: col)
        
        for move in captured {
        
            let marker = rows[move.row][move.col]
            
            marker.setPlayer(board.currentPlayer.markerColor)
            
            let scaleUp = SKAction.scale(by: (5/4), duration: 0.25)
            let scaleDown = SKAction.scale(by: (4/5), duration: 0.25)
            marker.run(SKAction.sequence([scaleUp, scaleDown]))
        }
        
        board.currentPlayer = board.currentPlayer.opponent
        
    }
    
    func makeAIMove() {
    
        DispatchQueue.global(attributes: .qosUserInitiated).async { [unowned self] in
            
            let strategistTime = CFAbsoluteTimeGetCurrent()
            
            guard let move = self.strategist.bestMoveForActivePlayer() as? Move else { return }
            
            let delta = CFAbsoluteTimeGetCurrent() - strategistTime
            
            DispatchQueue.main.async{ [unowned self] in
                
                self.rows[move.row][move.col].setPlayer(.choice)
                
                let aiTimeCeiling = 2.0
                
                let delay = min(aiTimeCeiling - delta, aiTimeCeiling)
                
                DispatchQueue.main.after(when: .now() + delay) { [unowned self] in
                    
                    self.makeMove(row: move.row, col: move.col)
                    
                }
            }
        }
    
    }
}
