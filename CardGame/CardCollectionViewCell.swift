//
//  CardCollectionViewCell.swift
//  CardGame
//
//  Created by 張永霖 on 2021/3/20.
//

import UIKit

class CardCollectionViewCell: UICollectionViewCell {
    
    // 顯示手牌用
    @IBOutlet weak var imageView: UIImageView!
    
    // 紀錄這是哪一張牌
    var cardValue:Int = 0
    
}
