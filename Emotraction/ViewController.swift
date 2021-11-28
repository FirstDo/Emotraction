//
//  ViewController.swift
//  Emotraction
//
//  Created by 김도연 on 2021/09/23.
//

import UIKit
import Speech
import FirebaseAuth
import FirebaseFirestore

class ViewController: UIViewController {

    //MARK: - OUTLET
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var AppleButton: UIButton!
    
    //MARK: - Local Properties
//    var userList = [String]()
//    var botList = [String]()
    
    var messageList = [Message]()
    
    let threeAddress = "http://163.239.28.25:5000/three"
    let sevenAddress = "http://163.239.28.25:5000/seven"
    let modelKey = "ModelKey"

    //MARK: - apple Speech to Text
    let audioEngine = AVAudioEngine()
    let speechReconizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale(identifier: "ko_KR"))
    let request = SFSpeechAudioBufferRecognitionRequest()
    var task: SFSpeechRecognitionTask!
    var isStart: Bool = false
    
    @IBAction func SelectModel(_ sender: UISegmentedControl) {
        let value = sender.selectedSegmentIndex
        UserDefaults.standard.set(value, forKey: modelKey)
        
        var modelName = ""
        var message = ""
        
        switch value {
        case 0:
            modelName = "3가지 감정분류 모델"
            message = "서버에서 NewEmotion.py 를 실행해주세요"
        case 1:
            modelName = "7가지 감정분류 모델"
            message = "서버에서 TestEmotion.py 를 실행해주세요"
        case 2:
            modelName = "개발중..."
            message = "다른 모델을 선택해주세요"
        default:
            modelName = "개발중..."
            message = "다른 모델을 선택해주세요"
        }
        alertView(message: message, title: modelName)
    }
    
    
    @IBAction func StartOrStop(_ sender: Any) {
        isStart = !isStart
        
        if isStart {
            stateLabel.text = "Recording..."
            stateLabel.textColor = .systemRed
            AppleButton.tintColor = .systemRed
            startSpeechRecognization()
        } else {
            stateLabel.text = "Waiting..."
            stateLabel.textColor = .black
            AppleButton.tintColor = .black
            cancelSpeechRecognization()
        }
    }
    
    func requestPermission() {
        self.AppleButton.isEnabled = false
        SFSpeechRecognizer.requestAuthorization { authState in
            OperationQueue.main.addOperation {
                if authState == .authorized {
                    print("ACCEPTED")
                    self.AppleButton.isEnabled = true
                } else if authState == .denied {
                    self.alertView(message: "User denied the permission")
                } else if authState == .notDetermined {
                    self.alertView(message: "In user phone there is no speech recognization")
                } else if authState == .restricted {
                    self.alertView(message: "User has been restricted for using the speech recognization")
                }
            }
        }
    }
    
    func startSpeechRecognization() {
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch let error {
            alertView(message: "Error comes here for starting the audio listner = \(error.localizedDescription)")
        }
        
        guard let myRecognization = SFSpeechRecognizer() else {
            self.alertView(message: "Recognization is not allow on your local")
            return
        }
        
        if !myRecognization.isAvailable {
            self.alertView(message: "Recognization is free right now, Please try agian after some time.")
        }
        
        task = speechReconizer?.recognitionTask(with: request, resultHandler: { response, error in
            guard let response = response else {
                return
            }
            let message = response.bestTranscription.formattedString
            print("Message: \(message)")
            self.messageLabel.text = message
        })
    }
    
    func cancelSpeechRecognization() {
        print(#function)
        task.finish()
        task.cancel()
        task = nil
        request.endAudio()
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    //Show alertView
    func alertView(message: String, title: String = "Error occured...!") {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            
        }))
        self.present(controller, animated: true, completion: nil)
    }
    
    //테이블뷰를 맨 마지막으로 스크롤하는 함수
    func scrollToBottom() {
        if messageList.count > 0 {
            let lastIndexPath = IndexPath(row: messageList.count - 1, section: 0)
            chatTableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
        }
        
    }
    
    //메시지를 서버로 보내고, 감정응답을 받는다.
    @IBAction func sendMessage(_ sender: Any) {
        guard let message = messageLabel.text, message.count > 0, message != "아무 말이나 해보세요" else {
            alertView(message: "보낼 메시지가 없습니다")
            return
        }
        send(message: message)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = Auth.auth().currentUser?.email == "usera@gmail.com" ? "A" : "B"
        title = "채팅 (\(user))"
        loadMessages()
        messageView.layer.cornerRadius = 10
        
        AppleButton.tintColor = .black
        stateLabel.text = "Waiting..."
        
        sendButton.backgroundColor = .systemOrange
        sendButton.layer.cornerRadius = 5
        sendButton.tintColor = .white
        
        requestPermission()
        
        //tableView setting
        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTableView.separatorStyle = .none
        chatTableView.allowsSelection = false
        
        let messageCell = UINib(nibName: "ChatTableViewCell", bundle: nil)
        chatTableView.register(messageCell, forCellReuseIdentifier: "cell")
        let messageCell2 = UINib(nibName: "ChatTableViewCell2", bundle: nil)
        chatTableView.register(messageCell2, forCellReuseIdentifier: "cell2")
        
        
        //기본 모델은 3가지 감정분류 모델
        UserDefaults.standard.set(0, forKey: modelKey)
        alertView(message: "서버에서 NewEmotion.py를 선택해주세요", title: "3가지 감정분류 모델")
    }
    
    //fire cloud 에서 메시지를 가져오는 부분
    private func loadMessages() {
        let db = Firestore.firestore()
        
        db.collection("messages").order(by: "date").addSnapshotListener { querySnapshot, error in
            self.messageList.removeAll()
            
            if let e = error {
                print(e.localizedDescription)
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    snapshotDocuments.forEach { doc in
                        let data = doc.data()
                        if let sender = data["sender"] as? String, let body = data["body"] as? String, let emotion = data["emotion"] as? String {
                            self.messageList.append(Message(sender: sender, body: body, emotion: emotion))
                            
                            DispatchQueue.main.async {
                                self.chatTableView.reloadData()
                                self.scrollToBottom()
                            }
                        }
                    }
                }
            }
        }
    }
}

//tableViewDelegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageList.count
    }
    
    //cell의 동적높이 구현
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let target = messageList[indexPath.row]
        
        if target.sender == Auth.auth().currentUser?.email {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ChatTableViewCell else {
                return UITableViewCell()
            }
            cell.textMessage.text = target.body
            cell.emotion.text = nil
            return cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as? ChatTableViewCell2 else {
                return UITableViewCell()
            }
            cell.textMessage.text = target.body
            cell.emotion.text = target.emotion
            return cell
        }
    }
}

