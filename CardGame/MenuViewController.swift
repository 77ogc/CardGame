//
//  MenuViewController.swift
//  CardGame
//
//  Created by 張永霖 on 2021/3/20.
//

import UIKit

class MenuViewController: UIViewController {

    let debugString = "[MenuVC] : "
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            // 頁面標題名稱
            self.title = "小動"
        // Do any additional setup after loading the view.
        

    }

    @IBAction func startMocking(_ sender: Any) {
        
        // 建立 警告提示框
        let alertController = UIAlertController(title: "鬧？", message: "就會玩還點開？", preferredStyle: .alert)
        
        // 建立 點選確認鍵  handler 可以做 確認後要運做的事情
        let okAction = UIAlertAction(title: "好的抱歉", style: .default, handler: {_ in self.log("成功羞辱人")})
        
        // 將確認鍵加入提示框內
        alertController.addAction(okAction)
        
        // 跳出提示框
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func startGame(_ sender: Any) {
        
        // 按下開始
        log("進入遊戲")
 
    }
    
    
    // Terminal debug log
    func log(_ string:String){
        print("\(debugString)\(string)")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// 讓手機橫著 因為是在UINavigationController下
extension UINavigationController {

override open var shouldAutorotate: Bool {
    get {
        if let visibleVC = visibleViewController {
            return visibleVC.shouldAutorotate
        }
        return super.shouldAutorotate
    }
}

override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
    get {
        if let visibleVC = visibleViewController {
            return visibleVC.preferredInterfaceOrientationForPresentation
        }
        return super.preferredInterfaceOrientationForPresentation
    }
}

override open var supportedInterfaceOrientations: UIInterfaceOrientationMask{
    get {
        if let visibleVC = visibleViewController {
            return visibleVC.supportedInterfaceOrientations
        }
        return super.supportedInterfaceOrientations
    }
}}

