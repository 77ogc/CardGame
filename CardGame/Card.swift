//
//  Card.swift
//  CardGame
//
//  Created by 張永霖 on 2021/3/20.
//


import Foundation

class Card {
    
    init() {
        cardPoints = 0
        cardValue = 0
    }
    var cardValue:Int
    var cardPoints:Int
}

class TitleCard : Card {
    override init() {
        
        // 先醃呼叫父類別 初始化
        super .init()
        
        // 為了UDP封包開頭辨識用
        self.cardPoints = 999
        self.cardValue = 999
    }
}


