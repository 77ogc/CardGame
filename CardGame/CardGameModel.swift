//
//  CardGameModel.swift
//  CardGame
//
//  Created by 張永霖 on 2021/3/20.
//

import Foundation
import UIKit

class CardGameModel {
    
    init() {
        setDeckOfPlayerCards()
        packCards()
    }
    
    // 橋牌賽局的組成要件
    private var deckOfCards = [Card]()
    private var king:Int = 0
    private var thisTurnSuit = 0
    private var thisTurnDealCardsNumber = 0
    private var whoseTurnToDeal:Int = 0
    private var packsToWin:Int = 0
    private var playerMySelf:Player = Player()
    private var saveDeckData:String = ""
    private var savePlayerData:String = ""
    public var thisTurnCard = [0,0,0,0]
    
    // 打包牌組資料
    private func packCards() {
        var data:String = ""
        for i in 0...deckOfCards.count - 1 {
            data.append(String(deckOfCards[i].cardValue))
        }
        
        // 存入牌組資料準備送出
        saveDeckData.append(data)
                
    }
    
    public func readSuitAndNumber(_ data:String) -> Int {
        
        // 只應該有兩個字
        if data.count != 2 {
            return -1
        }
    
        // 回傳值
        var value = 0
        
        // 讀取花色
        let suit = (data as NSString).substring(with: NSMakeRange(0,1))
        
        // 花色分別為 黑桃 愛心 方塊 梅花 無王
        if(suit == "S" || suit == "s") {
            value  = 10
        }
        else if(suit == "H" || suit == "h") {
            value  = 20
        }
        else if(suit == "D" || suit == "d") {
            value  = 30
        }
        else if(suit == "C" || suit == "c") {
            value  = 40
        }
        else if(suit == "N" || suit == "n") {
            value  = 50
        }
        else {
            
            // 花色輸入錯誤
            return -1
        }
        
        // 讀取 墩數
        let num = (data as NSString).substring(with: NSMakeRange(1,1))
        
        // 加入 回傳值
        if Int(num) != nil {
            
            if Int(num)! > 0 && Int(num)! < 5 {
                
                value += Int(num)!
                
            } else {
                
                // 墩數輸入錯誤
                return -1
            }
        } else {
            
            // 墩數輸入錯誤
            return -1
        }
        
        return value
    }
    
    // 打包 玩家資訊吻被傳送
    public func packPlayerInfo () {
        
        var data = ""
        data.append(self.playerMySelf.getPlayerName())
        data.append(String(self.playerMySelf.getPlayerNumber()))
    }
    
    // 拿資料
    public func getData(_ type:Int) -> String {
        
        // 拿牌組資料
        if type == 1 {
            return self.saveDeckData
        }
        
        // 拿玩家資料
        if type == 2 {
            return self.savePlayerData
        }
        
        // 回傳 ""
        return ""
        
    }
    
    // 重置資料
    public func resetData() {
        
        // 設為 ""
        self.saveDeckData = ""
        self.savePlayerData = ""
    }
    
    // 產生一組牌
    private func setDeckOfPlayerCards() {
        
        // 循環 52 次 產生一組牌並放進牌組內
        for i in 1...4 {
            for j in 2...14 {
                
                // Card 物件
                let tempCard = Card()
                
                // 產生 牌 的代表值
                let num = 100 * i + j
                tempCard.cardValue = num
                
                // 計算牌的價值
                if (num / 10 ) %  10 == 1 {
                    tempCard.cardPoints = num - (num / 10) * 10
                } else {
                    tempCard.cardPoints = 0
                }
                // 放進牌組
                deckOfCards.append(tempCard)
            }
        }
        
        // 洗亂牌組 並檢查點數是否足夠
        var pointCheck = false
        
        while !pointCheck {
            
            // 洗亂牌組
            deckOfCards.shuffle()
            
            //檢查點數是否足夠
            pointCheck = checkPoint()
            
        }
        
    }
    
    // 檢查點數夠不夠
    private func checkPoint() -> Bool {
        
        var deck1 = [Card]()
        var deck2 = [Card]()
        var deck3 = [Card]()
        var deck4 = [Card]()
        
        // 檢查第一副牌
        var tempPoint = 0
        for i in 0...12 {
            tempPoint += deckOfCards[i].cardPoints
            deck1.append(deckOfCards[i])
        }
        if tempPoint < 5 {
            return false
        }
        
        // 檢查第二副牌
        tempPoint = 0
        for i in 13...25 {
            tempPoint += deckOfCards[i].cardPoints
            deck2.append(deckOfCards[i])
        }
        if tempPoint < 5 {
            return false
        }
        
        // 檢查第三副牌
        tempPoint = 0
        for i in 26...38 {
            tempPoint += deckOfCards[i].cardPoints
            deck3.append(deckOfCards[i])
        }
        if tempPoint < 5 {
            return false
        }
        
        // 檢查第四副牌
        tempPoint = 0
        for i in 39...51 {
            tempPoint += deckOfCards[i].cardPoints
            deck4.append(deckOfCards[i])
        }
        if tempPoint < 5 {
            return false
        }
        
        // 整理排序
        deck1 = deck1.sorted(by: { $0.cardValue < $1.cardValue })
        deck2 = deck2.sorted(by: { $0.cardValue < $1.cardValue })
        deck3 = deck3.sorted(by: { $0.cardValue < $1.cardValue })
        deck4 = deck4.sorted(by: { $0.cardValue < $1.cardValue })
        
        // 放回牌組等待傳送 Tag card
        let tempCard = TitleCard()
        deckOfCards.removeAll()
    
        // 將 封包TAG 和 排序好的 加入整副牌
        deckOfCards.append(tempCard)
        deckOfCards += deck1
        deckOfCards += deck2
        deckOfCards += deck3
        deckOfCards += deck4
        
        return true
        
    }
    
    // Remove
    public func removeCardsFromDeck(_ num:Int) {
        self.playerMySelf.removeCardsFromDeck(num)
    }
    
    public func removeCardsFromThisTurn() {
        self.thisTurnCard[0] = 0
        self.thisTurnCard[1] = 0
        self.thisTurnCard[2] = 0
        self.thisTurnCard[3] = 0
    }
    
    // Set
    public func storeCardsData(_ index:Int, _ num:Int) {
        
        // 貯存這把四張的資料
        thisTurnCard[index - 1] = num
        
    }
    
    public func setPlayerName(_ name:String) {
        self.playerMySelf.setPlayerName(name)
    }
    
    public func setPlayerNumber( _ num:Int) {
        self.playerMySelf.setPlayerNumber(num)
    }
    
    public func setPlayerCards( _ deck:[Card]) {
        self.playerMySelf.setPlayerCards(deck)
    }
    
    public func setGameKing( _ num:Int) {
        self.king = num
    }
    
    public func setGameWinningPackNum( _ num:Int) {
        self.packsToWin = num
    }
    
    public func setWhoseTurnToDeal( _ num:Int) {
        self.whoseTurnToDeal = num
    }
    
    public func setThisTurnSuit( _ num:Int) {
        self.thisTurnSuit = num
    }
    
    public func addThisTurnDealCardsNumber() {
        self.thisTurnDealCardsNumber += 1
    }
    
    public func setThisTurnDealCardsNumberToZero() {
        self.thisTurnDealCardsNumber = 0
    }
    
    
    // Get
    public func getPlayerName() -> String {
       return self.playerMySelf.getPlayerName()
    }
    
    public func getPlayerNumber() -> Int {
        return self.playerMySelf.getPlayerNumber()
    }
    
    public func getPlayerCardCount() -> Int {
        return self.playerMySelf.getPlayerCardNumber()
    }
    
    public func getPlayerMockingCount() -> Int {
        return self.playerMySelf.getPlayerMockingCount()
    }
    
    public func getGameKing() -> Int {
        return self.king
    }
    
    public func getThisTurnSuit() -> Int {
        return self.thisTurnSuit
    }
    
    public func getThisTurnDealCardsNumber() -> Int {
        return self.thisTurnDealCardsNumber
    }
    
    public func getThisTurnDealCardsPlayerNumber() -> Int {
        return self.whoseTurnToDeal
    }

    public func getPlayerCardsName(_ index:Int) -> Int {
        return self.playerMySelf.getPlayerCardsName(index)
    }
    
    public func getThisTurnCards() -> [Int] {
        return self.thisTurnCard
    }
}

