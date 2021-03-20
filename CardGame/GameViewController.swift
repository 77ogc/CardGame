//
//  GameViewController.swift
//  CardGame
//
//  Created by 張永霖 on 2021/3/20.
//

import UIKit
import CocoaAsyncSocket

class GameViewController: UIViewController, GCDAsyncUdpSocketDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // 用來顯示手牌
    @IBOutlet weak var collectionView: UICollectionView!
    
    // 廣播用的IP位址
    let IP = "255.255.255.255"
    
    // 建立 UDP scocket 物件
    var udpSocket: GCDAsyncUdpSocket!
    
    // Debug 字串
    let debugString = "[GameVC] : "
    
    // 橋牌遊戲 發牌和王牌按鈕 王牌花色 其他人出的牌
    var bridgeGame = CardGameModel()
    @IBOutlet weak var dealButton: UIButton!
    @IBOutlet weak var kingButton: UIButton!
    @IBOutlet weak var imageViewOne: UIImageView!
    @IBOutlet weak var imageViewTwo: UIImageView!
    @IBOutlet weak var imageViewThree: UIImageView!
    @IBOutlet weak var imageViewFour: UIImageView!
    @IBOutlet weak var playerOneName: UILabel!
    @IBOutlet weak var playerTwoName: UILabel!
    @IBOutlet weak var playerThreeName: UILabel!
    @IBOutlet weak var playerFourName: UILabel!
    @IBOutlet weak var winningPack: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 橫著顯示
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        
        // 創建 UDP scocket
        udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        
        // 開始聆聽 Port : 8000
        bindPort()
        
        // 取得玩家資訊
        setPlayerInfo()
        
        // 代理顯示collectionView
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        // 關閉 UDP socket
        udpSocket.close()
        
        // Debug
        log("關閉Socket")
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeLeft
    }

    override var shouldAutorotate: Bool {
        return true
    }
    
    //MARK: - socket
    func bindPort() {
        do {
            
            // 綁定 Port : 8000
            try udpSocket.bind(toPort: UInt16(8000))
            
            // Debug
            log("綁定成功")
            
        }catch {
            
            // Debug
            log("綁定失敗")
        }
    
        do {
            
            // 開始廣播
            try udpSocket.enableBroadcast(true)
            
            // Debug
            log("開始廣播")
            
        }catch {
            
            // Debug
            log("無法廣播")
            
        }
        
        do {
            
            // 開始接收訊息
            try udpSocket.beginReceiving()
            
            // Debug
            log("開始接收訊息")
            
        }catch {
            
            // Debug
            log("無法接收訊息")
            
        }
        
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        
        // 接收到的訊息
        let recieveData = String(data: data, encoding: String.Encoding.utf8)!
        
        // Debug
        log("接收到訊息:\(recieveData)")
        
        // 更新整個遊戲資訊
        processData(recieveData)
    }
    
    //MARK: - Bridge
    @IBAction func setKing(_ sender: Any) {
        
        // 接收回傳值
        var check = -1
        
        if(bridgeGame.getGameKing() == 0) {
        
            // 跳出 輸入王牌訊息框
            let alertController = UIAlertController(title: "王牌", message: "輸入花色和數字", preferredStyle: .alert)
            
            // 新增王牌輸入框
            alertController.addTextField { (textField: UITextField!) -> Void in
                textField!.placeholder = "花色數字"
            }
            
            // 取消按鈕
            let notOkAction = UIAlertAction(title: "取消", style: .default, handler: nil)
            
            // 確認按鈕
            let okAction = UIAlertAction(title: "確認", style: .default) { [self] (alert) in
                
                // 看看打的對不對
                if let suitAndNum = alertController.textFields?.first! {
                                    
                    // 看是不是空的
                    if let data = suitAndNum.text, data != "" {
                                        
                        // 讀取花色
                        check = self.bridgeGame.readSuitAndNumber(data)
                        
                        // 看回傳值做事情
                        if check == -1 {
                            
                            // 跳出嘲諷訊息
                            let alertController = UIAlertController(title: "錯", message: "錯錯錯錯", preferredStyle: .actionSheet)
                            
                            // 確認按鈕
                            let okAction = UIAlertAction(title: "Sorry", style: .default, handler: nil)
                            alertController.addAction(okAction)
                                                                                    
                            // 顯示出來
                            self.present(alertController, animated: true, completion: nil)
                        } else {
                            
                            //Debug
                            self.log("花色為 \(check)")
                            
                            // 加上花色封包TAG 996 -> 996xxx 和 出牌順序
                            var playerNumber = self.bridgeGame.getPlayerNumber()
                            
                            // 7414 設定成 1
                            if playerNumber > 4 {
                                playerNumber = 1
                            }
                            // 3 號 下一家 是 1 固設定成 0
                            if playerNumber == 4 {
                                playerNumber = 0
                            }
                            
                            check += 996000 + (playerNumber + 1) * 100
                            
                            // 花色和墩數傳送出去
                            self.udpSocket.send(String(check).data(using: .utf8)!, toHost: IP, port: UInt16(8000), withTimeout: -1, tag: 0)
                        }
                                        
                    } else {
                                        
                        // Debug
                        log("花色空白")
                    }

                }
                
                
            }
            
            // 顯示確認取消按鈕
            alertController.addAction(notOkAction)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func dealPlayingCards(_ sender: Any) {
        if bridgeGame.getPlayerNumber() == 7414 {
            
            // 拿牌組資料
            let data = bridgeGame.getData(1).data(using: .utf8)
                        
            // 廣播訊息到 Por : 8000
            udpSocket.send(data!, toHost: IP, port: UInt16(8000), withTimeout: -1, tag: 0)
        
        } else if bridgeGame.getPlayerMockingCount() == 1 {
            
            // 跳出嘲諷訊息
            let alertController = UIAlertController(title: "你?", message: "不夠格發牌啦", preferredStyle: .alert)

            // 確認按鈕
            let okAction = UIAlertAction(title: "是的抱歉", style: .default, handler: nil)
            
            // 將確認加入警示
            alertController.addAction(okAction)
            
            // 顯示出來
            self.present(alertController, animated: true, completion: nil)
            
        } else if bridgeGame.getPlayerMockingCount() > 1 {
            
            // 跳出嘲諷旭襲
            let alertController = UIAlertController(title: "你還來?", message: "講不聽?", preferredStyle: .alert)

            // 確認按鈕
            let okAction = UIAlertAction(title: "非常抱歉", style: .default, handler: nil)
            
            // 將確認加入警示
            alertController.addAction(okAction)
            
            // 顯示出來
            self.present(alertController, animated: true, completion: nil)
            
            // 關閉按鈕顯示
            let btn = sender as! UIButton
            btn.isHidden = true
        }
    }
    
    func readDataTag(_ data:String) -> Int {
        
        // 讀取封包TAG
        let tag = (data as NSString).substring(with: NSMakeRange(0,3))
        let returnValue = Int(tag)!
        
        return returnValue
    }
    
    func setDeckFromData(_ data:String) {
        
        // Debug
        log("讀取牌組")
        
        // 把資料轉換成牌
        var startIndex = 0
        let numberOfCard = 39
        
        // 分配排序
        var deck = [Card]()
        if bridgeGame.getPlayerNumber() == 7414 {
            startIndex = 39 * 0 + 3
        }
        if bridgeGame.getPlayerNumber() == 1 {
            startIndex = 39 * 1 + 3
            
        }
        if bridgeGame.getPlayerNumber() == 2 {
            startIndex = 39 * 2 + 3
        }
        if bridgeGame.getPlayerNumber() == 3 {
            startIndex = 39 * 3 + 3
        }
        
        // 讀取封包 牌組訊息
        let deckData = (data as NSString).substring(with: NSMakeRange(startIndex ,numberOfCard))
      
        // Debug
        log("讀取到一副牌 -> \(deckData)")
        
        // 字串轉換成牌組
        for i in 0...12 {
            
            let tempCard = Card()
            tempCard.cardValue = Int((deckData as NSString).substring(with: NSMakeRange( i * 3 , 3 )))!
            deck.append(tempCard)
        }
        
        // Debug
        log("轉換成牌組")
        
        // 交給玩家牌
        bridgeGame.setPlayerCards(deck)
        
        // Debug
        log("將牌交到玩家手上")
        
        // 重新讀取 collectionView
        collectionView.reloadData()
        
    }
    
    func setKingForThisGame(_ data:String) {
        
        // 出牌順序
        let order = Int((data as NSString).substring(with: NSMakeRange( 3 , 1 )))!
        bridgeGame.setWhoseTurnToDeal(order)
        if order == 1 {
            playerOneName.textColor = UIColor.red
        } else if order == 2 {
            playerTwoName.textColor = UIColor.red
        } else if order == 3 {
            playerThreeName.textColor = UIColor.red
        }
        else if order == 4 {
            playerFourName.textColor = UIColor.red
        }

        
        // Debug
        log("\(order)號玩家先出牌")
        
        // 拿花色和墩數
        let value = Int((data as NSString).substring(with: NSMakeRange( 4 , 2 )))!
        
        //
        var playerNumber = bridgeGame.getPlayerNumber()
        if playerNumber > 4 {
            playerNumber = 1
        }
        
        if order % 2 == 0 && playerNumber % 2 == 0 {
            winningPack.text = String(7 + value % 10 - 1)
        } else {
            winningPack.text = String(7 - value % 10 + 1)
        }
        
        if order % 2 != 0 && playerNumber % 2 != 0 {
            winningPack.text = String(7 - value % 10 + 1)
        } else {
            winningPack.text = String(7 + value % 10 - 1)
        }
        
        // 分開花色和墩數
        let suit = value / 10
        let pack = value % 10
        
        // 設定遊戲的王和勝利條件
        bridgeGame.setGameKing(suit)
        bridgeGame.setGameWinningPackNum(pack)
        
        //♠❤♦♣✖︎ 設定 花色到按鈕上
        var data = ""
        if(suit == 1){
            data = "♠ \(pack)"
            kingButton.setTitleColor(UIColor.black, for: .normal)
        } else if suit == 2 {
            data = "❤ \(pack)"
            kingButton.setTitleColor(UIColor.red, for: .normal)
        } else if suit == 3 {
            data = "♦ \(pack)"
            kingButton.setTitleColor(UIColor.red, for: .normal)
        } else if suit == 4 {
            data = "♣ \(pack)"
            kingButton.setTitleColor(UIColor.black, for: .normal)
        } else if suit == 5 {
            data = "✖︎ \(pack)"
            kingButton.setTitleColor(UIColor.darkGray, for: .normal)
        }
        kingButton.setTitle(data, for: .normal)
        
        // Debug
        log("設定好王牌花色墩數")
        
    }
    
    func setFourPlayerName(_ data:String) {
        
        // 拿玩家名字長度
        let nameCount = Int((data as NSString).substring(with: NSMakeRange( 4 , 1 )))!
        
        // 拿玩家代號
        let playerNumber = Int((data as NSString).substring(with: NSMakeRange( 3 , 1 )))!
        
        // 拿玩家名字
        let name = (data as NSString).substring(with: NSMakeRange(5 ,nameCount))
        
        // 名字改到Label上
        if playerNumber == 1 {
            playerOneName.text = name
        } else if playerNumber == 2 {
            playerTwoName.text = name
        } else if playerNumber == 3 {
            playerThreeName.text = name
        }
        else if playerNumber == 4 {
            playerFourName.text = name
       }
        
        // Debug
        log("接收到玩家資訊並更改名字到螢幕上")

    }
    
    func setRecievedCards(_ data:String) {
        
        // 看誰出的牌
        let playerNumber = Int((data as NSString).substring(with: NSMakeRange( 3 , 1 )))!
        
        // 出的牌放到螢幕上 下一個出牌者顯示成紅色
        let recievedCards = (data as NSString).substring(with: NSMakeRange( 4 , 3 ))
        
        // store card
        bridgeGame.storeCardsData(playerNumber, Int(recievedCards)!)
        
        if playerNumber == 1 {
            imageViewOne.image = UIImage(named: recievedCards)
            playerOneName.textColor = UIColor.black
            playerTwoName.textColor = UIColor.red
        } else if playerNumber == 2 {
            imageViewTwo.image = UIImage(named: recievedCards)
            playerTwoName.textColor = UIColor.black
            playerThreeName.textColor = UIColor.red
        } else if playerNumber == 3 {
            imageViewThree.image = UIImage(named: recievedCards)
            playerThreeName.textColor = UIColor.black
            playerFourName.textColor = UIColor.red
        }
        else if playerNumber == 4 {
            imageViewFour.image = UIImage(named: recievedCards)
            playerFourName.textColor = UIColor.black
            playerOneName.textColor = UIColor.red
        }
        
        // 記錄第一張出的花色
        if bridgeGame.getThisTurnDealCardsNumber() == 0 {
            
            // 哪一張牌
            let card = Int(recievedCards)!
            let suit = card / 100
            
            // 儲存花色
            bridgeGame.setThisTurnSuit(suit)
        }
        
        // 新增接收到牌的次數
        bridgeGame.addThisTurnDealCardsNumber()
        
    }
    
    func processData(_ data:String) {
        
        // 第一層訊息過略
        let dataType = readDataTag(data)
        
        // 情況一 收到牌組訊息 開頭 999
        if dataType == 999 {
            setDeckFromData(data)
        }
        
        // 情況二 收到玩家資訊 開頭 998
        if dataType == 998 {
            setFourPlayerName(data)
        }
        
        // 情況三 收到出牌訊息 開頭 997
        if dataType == 997 {
            setRecievedCards(data)
            checkThisRoundWinner()
        }
        
        // 情況三 收到王牌花色訊息 開頭 996
        if dataType == 996 {
            setKingForThisGame(data)
        }
        
        // 開頭 994 reset game
        if dataType == 994 {
            
        }
    }
    
    func checkThisRoundWinner() {
        
        log("Deal number:\(bridgeGame.getThisTurnDealCardsNumber())")
        
        // 確定出了四張牌
        if bridgeGame.getThisTurnDealCardsNumber() == 8 {
            
            // 看這把誰贏 先拿王牌花色 這把第一張花色
            let thisGameKing = bridgeGame.getGameKing()
            let thisTurnSuit = bridgeGame.getThisTurnSuit()
            var thisTurnCards = bridgeGame.getThisTurnCards()
            var winner = 0
            var thisTurnExistKing = false
            
            log("king:\(thisGameKing)")
            log("This turn suit:\(thisTurnSuit)")
            log("This turn cards:\(thisTurnCards)")
            
            // 先看有沒有王 王比大小
            if thisGameKing != 5 {
                for i in 0...3 {
                    if thisTurnCards[i] / 100 == thisGameKing {
                        thisTurnExistKing = true
                    }
                }
            }
            
            // Debug
            log("有王 = \(thisTurnExistKing)")
            
            // 有王
            if thisTurnExistKing == true {
                for i in 0...3 {
                    if thisTurnCards[i] / 100 != thisGameKing {
                        thisTurnCards[i] = thisTurnCards[i] / 100
                    }
                }
                
                log("In king This turn card:\(thisTurnCards)")
                
                // 找贏家位置
                let highestValue = thisTurnCards.max()
                let highestIndex = thisTurnCards.firstIndex(of: highestValue!)
                
                
                log("Win value:\(highestValue!)")
                log("Win index:\(highestIndex!)")
                // 找到贏家
                winner = highestIndex! + 1
                
                // Debug
                log("出王的贏家 = \(winner)")
            }
            
            // 再比這一輪的花色大小
            if winner == 0 {
                for i in 0...3 {
                    if thisTurnCards[i] / 100 != thisTurnSuit {
                        thisTurnCards[i] = thisTurnCards[i] / 100
                    }
                }
                log("In color This turn card:\(thisTurnCards)")
                
                // 找贏家是哪一位
                let highestValue = thisTurnCards.max()
                let highestIndex = thisTurnCards.firstIndex(of: highestValue!)
                
                log("Win value:\(String(describing: highestValue))")
                log("Win index:\(String(describing: highestIndex))")
                
                // 找到贏家
                winner = highestIndex! + 1
                
                // Debug
                log("沒出王的贏家 = \(winner)")
            }
            
            // 設定贏的人 墩數減一
            var playerNumber = bridgeGame.getPlayerNumber()
            if playerNumber > 4 {
                playerNumber = 1
            }
            
            if winner % 2 == 0 && playerNumber % 2 == 0  && winner != 0 {
                winningPack.text = String(Int(winningPack.text!)! - 1)
            }
            
            if winner % 2 != 0 && playerNumber % 2 != 0 {
                winningPack.text = String(Int(winningPack.text!)! - 1)
            }
            
            // 換他出牌
            bridgeGame.setWhoseTurnToDeal(winner)
            if winner == 1 {
                playerOneName.textColor = UIColor.red
                playerTwoName.textColor = UIColor.black
                playerThreeName.textColor = UIColor.black
                playerFourName.textColor = UIColor.black
                
            } else if winner == 2 {
                playerOneName.textColor = UIColor.black
                playerTwoName.textColor = UIColor.red
                playerThreeName.textColor = UIColor.black
                playerFourName.textColor = UIColor.black
            } else if winner == 3 {
                playerOneName.textColor = UIColor.black
                playerTwoName.textColor = UIColor.black
                playerThreeName.textColor = UIColor.red
                playerFourName.textColor = UIColor.black
            }
            else if winner == 4 {
                playerOneName.textColor = UIColor.black
                playerTwoName.textColor = UIColor.black
                playerThreeName.textColor = UIColor.black
                playerFourName.textColor = UIColor.red
            }
            
            // Debug
            log("贏家是\(winner)")

            // 清空四張顯示
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                self.imageViewOne.image = nil
                self.imageViewTwo.image = nil
                self.imageViewThree.image = nil
                self.imageViewFour.image = nil
            }
            
            
            // 歸零
            bridgeGame.setThisTurnDealCardsNumberToZero()
            bridgeGame.setThisTurnSuit(0)
            bridgeGame.removeCardsFromThisTurn()
            
            // Debug
            log("清空牌組")
            
        }
    }
    
    func setPlayerInfo() {
        
        // 確認用 bool
        var correctName = false
        var correctNum = false
        
        // 跳出 輸入玩家訊息框
        let alertController = UIAlertController(title: "玩家資訊", message: "輸入名稱和代號", preferredStyle: .alert)
        
        // 新增名稱輸入框
        alertController.addTextField { (textField: UITextField!) -> Void in
            textField!.placeholder = "名稱"
        }
        // 新增代號輸入框
        alertController.addTextField { (textField: UITextField!) -> Void in
            textField!.placeholder = "代號"
        }
        
        // 確認按鈕
        let okAction = UIAlertAction(title: "確認", style: .default, handler: { [self] (action) in
            // 檢查輸入正確與否
            if let playerName = alertController.textFields?.first! {
                correctName = true
                self.bridgeGame.setPlayerName(String(playerName.text!))
            }
            
            // 檢查輸入是否為數字
            if let playerNumber = alertController.textFields?.last! {
                if Int(playerNumber.text!) != nil {
                    correctNum = true
                    self.bridgeGame.setPlayerNumber(Int(playerNumber.text!)!)
                }
            }
            
            // 有誤就再跳一次輸入框
            if(!correctNum || !correctName) {
                self.setPlayerInfo()
                self.log("有錯誤再輸入一次")
            }
            else {
                
                // 確認是否真的取得資訊
                self.log("玩家資訊 -> 名稱 \(self.bridgeGame.getPlayerName())" + " 代號 \(String(self.bridgeGame.getPlayerNumber()))")
                
                // 包裝好玩家資訊準備傳送
                var playerNumber = self.bridgeGame.getPlayerNumber()
                if playerNumber > 4 {
                    playerNumber = 1
                }
                let playerPacket = "998" + String(playerNumber) + String( self.bridgeGame.getPlayerName().count ) + self.bridgeGame.getPlayerName()
                
                // UDP 傳送給其他人知道
                self.udpSocket.send( playerPacket.data(using: .utf8)!, toHost: self.IP, port: UInt16(8000), withTimeout: -1, tag: 0)
                
            }
            })
        
        // 加入 alertController 並顯示
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
 
    //MARK: - CollectionViewCell
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // 回傳 手牌數量
        return bridgeGame.getPlayerCardCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // 將 cell 轉成 自定義的 class
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "card", for: indexPath) as! CardCollectionViewCell
        
        // 讀取手牌顯示到cell上
        cell.imageView.image = UIImage(named: String(bridgeGame.getPlayerCardsName(indexPath.row)))
        
        // 紀錄這格存放哪一張牌
        cell.cardValue = bridgeGame.getPlayerCardsName(indexPath.row)
                
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // 先生成一個 cell
        let cell = collectionView.cellForItem(at: indexPath) as? CardCollectionViewCell
        
        // 讀取出牌的名字
        let cardName = (cell?.cardValue)!
        
        // 轉換成中文
        let suit = Int(cardName) / 100
        var value = Int(cardName) % 100
        var name = ""
        if value == 14 {
            value = 1
        }
        if suit == 1 {
            name = "黑桃\(value)"
        } else if suit == 2 {
            name = "愛心\(value)"
        } else if suit == 3 {
            name = "方塊\(value)"
        } else if suit == 4 {
            name = "梅花\(value)"
        }
        
        log("點選手牌 -> \(name)")
        
        // UDP將手牌傳送出去
        var playNumber = bridgeGame.getPlayerNumber()
        if playNumber > 4 {
            playNumber = 1
        }
        
        // 先確認是換你出來牌 你才能出牌
        if playNumber > 0 { //== bridgeGame.getThisTurnDealCardsPlayerNumber()
            
            // 跳出嘲諷訊息
            let alertController = UIAlertController(title: "出牌訊息", message: "要出\(name)?", preferredStyle: .alert)

            // 確認按鈕
            let okAction = UIAlertAction(title: "是", style: .default) { (alert) in
                
                // 打包封包資料
                let prefix = "997\(playNumber)"
                let data = (prefix + String(cardName)).data(using: .utf8)
                self.udpSocket.send(data!, toHost: self.IP, port: UInt16(8000), withTimeout: -1, tag: 0)

                // 從手牌中刪掉
                self.bridgeGame.removeCardsFromDeck(cardName)

                // 重整collevtionView
                collectionView.reloadData()

                // Debug
                self.log("出牌 -> \(name)")
            }
            
            // 取消
            let notOkAction = UIAlertAction(title: "否", style: .default, handler: nil)
            
            // 將確認加入警示
            alertController.addAction(okAction)
            alertController.addAction(notOkAction)
            
            // 顯示出來
            self.present(alertController, animated: true, completion: nil)
        
        }
    
    }

    // Terminal debug log
    func log(_ string:String){
        print("\(debugString)\(string)")
    }

}


