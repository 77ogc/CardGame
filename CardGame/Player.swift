//
//  Player.swift
//  CardGame
//
//  Created by 張永霖 on 2021/3/20.
//

import Foundation

class Player {
    
    // 玩家資訊
    private var playerNumber = 0
    private var playerName = ""
    private var handOfCards = [Card]()
    private var numberOfCards = 0
    private var playerVictoryCount = 0
    private var mockingNumber = 0
    
    // Remove
    public func removeCardsFromDeck(_ num:Int) {
        
        var index = 0
        
        while true
        {
            if handOfCards[index].cardValue == num {
                handOfCards.remove(at: index)
                break
            } else {
                index += 1
            }
        }
    
        
    }
    
    // Set
    public func setPlayerName(_ playerName:String){
        self.playerName = playerName
    }
    
    public func setPlayerCards(_ handOfCards:[Card]){
        self.handOfCards = handOfCards
    }
    
    public func setPlayerNumber(_ playerNumber:Int) {
        self.playerNumber = playerNumber
    }
    
    public func removePlayerCards(_ index:Int) {
        handOfCards.remove(at: index)
    }
    
    // Get
    public func getPlayerName() -> String {
        return self.playerName
    }
    
    public func getPlayerNumber() -> Int {
        return self.playerNumber
    }
    
    public func getPlayerCardNumber() -> Int {
        return self.handOfCards.count
    }
    
    public func getPlayerMockingCount() -> Int {
        self.mockingNumber += 1
        return self.mockingNumber
    }
    
    public func getPlayerCardsName(_ num:Int) -> Int {
        return handOfCards[num].cardValue
    }
}

