//
//  ViewController.swift
//  Emotraction
//
//  Created by 김도연 on 2021/09/23.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var messageView: UITextView!
    @IBOutlet weak var chatTableView: UITableView!
    var userList = [String]()
    var botList = [String]()
    
    let randomEmoij = ["😀","😆","🙁","😡","🥶","😱","😢","😵‍💫","😐"]
    
    
    //테이블뷰를 맨 마지막으로 스크롤하는 함수
    func scrollToBottom() {
        if userList.count > 0 {
            let lastIndexPath = IndexPath(row: userList.count * 2 - 1, section: 0)
            chatTableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
        }
        
    }
    
    //메시지를 서버로 보내고, 감정응답을 받는다.
    @IBAction func sendMessage(_ sender: Any) {
        
        guard let message = messageView.text, message.count > 0 else {
            return
        }
        
        userList.append(message)
        messageView.text = nil
        
        //서버로부터 받은 감정처리하기 (일단은 랜덤으로 감정 보여주기)
        let idx = Int.random(in: 0..<randomEmoij.count)
        let emotion = randomEmoij[idx]
        botList.append(emotion)
        chatTableView.reloadData()
        scrollToBottom()
    }
    
    //MARK: - keyboard observer
    var willShowToken: NSObjectProtocol?
    var willHideToken: NSObjectProtocol?
    
    deinit {
        if let token = willShowToken {
            NotificationCenter.default.removeObserver(token)
        }
        
        if let token = willHideToken {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "채팅봇"
        
        
        willShowToken = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main, using: { [weak self] noti in
            
            if let frame = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let height = frame.cgRectValue.height
                
                
                self?.bottomConstraint.constant = height
                UIView.animate(withDuration: 0.3) {
                    self?.view.layoutIfNeeded()
                }
                self?.scrollToBottom()
            }
        })
        
        willHideToken = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main, using: { [weak self] noti in
        
            self?.bottomConstraint.constant = 0
            UIView.animate(withDuration: 0.3) {
                self?.view.layoutIfNeeded()
            }
        })

        
        //tableView setting
        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTableView.separatorStyle = .none
        //chatTableView.allowsSelection = false
        
        let myCell = UINib(nibName: "MyTableViewCell", bundle: nil)
        let botCell = UINib(nibName: "BotTableViewCell", bundle: nil)
        
        chatTableView.register(myCell, forCellReuseIdentifier: "userCell")
        chatTableView.register(botCell, forCellReuseIdentifier: "botCell")
        
        // Do any additional setup after loading the view.
    }

}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count * 2
    }
    
    //cell의 동적높이 구현
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //userCell
        if indexPath.row % 2 == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! MyTableViewCell
            cell.selectionStyle = .none
            cell.messageLabel.text = userList[indexPath.row / 2]
            return cell
        }
        //botCell
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "botCell", for: indexPath) as! BotTableViewCell
            cell.selectionStyle = .none
            cell.emotionLabel.text = botList[indexPath.row / 2]
            return cell
        }
    }
}

