//
//  ViewController.swift
//  Emotraction
//
//  Created by 김도연 on 2021/09/23.
//

import UIKit
import Speech

struct PostData: Codable {
    let text: String
}

struct EmotionData: Codable {
    let emotion: String
}

class ViewController: UIViewController {

    //MARK: - OUTLET
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    
    
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var AppleButton: UIButton!
    
    //MARK: - Local Properties
    var userList = [String]()
    var botList = [String]()
    //temp data
    let randomEmoij = ["😀","😆","🙁","😡","🥶","😱","😢","😵‍💫","😐"]
    
    
    //MARK: - apple Speech to Text
    let audioEngine = AVAudioEngine()
    let speechReconizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale(identifier: "ko_KR"))
    let request = SFSpeechAudioBufferRecognitionRequest()
    var task: SFSpeechRecognitionTask!
    var isStart: Bool = false

    
    
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
                if error != nil {
                    //self.alertView(message: error.debugDescription)
                } else {
                    //self.alertView(message: "Problem in giving the response")
                }
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
    
    
    
    
    //alertView
    func alertView(message: String) {
        let controller = UIAlertController(title: "Error occured...!", message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            
        }))
        self.present(controller, animated: true, completion: nil)
    }
    
    
    //테이블뷰를 맨 마지막으로 스크롤하는 함수
    func scrollToBottom() {
        if userList.count > 0 {
            let lastIndexPath = IndexPath(row: userList.count * 2 - 1, section: 0)
            chatTableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
        }
        
    }
    
    //메시지를 서버로 보내고, 감정응답을 받는다.
    @IBAction func sendMessage(_ sender: Any) {
        
        guard let message = messageLabel.text, message.count > 0, message != "아무 말이나 해보세요" else {
            return
        }
        
        if isStart == true {
            StartOrStop(self)
        }
        
        
        
        userList.append(message)
        messageLabel.text = "아무 말이나 해보세요"
        
        //서버 통신
        print("서버통신")
        let address = "http://192.168.0.17:5000/text"
        guard let url = URL(string: address) else {fatalError("InvalidURL")}
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        
        let messageData = PostData(text: message)
        let d = try? JSONEncoder().encode(messageData)
        
        request.httpBody = d
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("task ERROR")
                print(error.localizedDescription)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("httpResonse ERROR")
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print(httpResponse.statusCode,"error")
                return
            }
                        
            //서버로 부터 받은 감정값 파싱
            if let data = data {
                do {
                    let t = try JSONDecoder().decode(EmotionData.self, from: data)
                    print("서버에서 응답을 받았습니다\n서버에서 응답을 받았습니다\n서버에서 응답을 받았습니다\n서버에서 응답을 받았습니다\n서버에서 응답을 받았습니다\n")
                    print(t)
                } catch let error {
                    print("data parsing error")
                    print(error.localizedDescription)
                }
            }
        }
        task.resume()
        
        //서버로부터 받은 감정처리하기 (일단은 랜덤으로 감정 보여주기)
        let idx = Int.random(in: 0..<randomEmoij.count)
        let emotion = randomEmoij[idx]
        botList.append(emotion)
        chatTableView.reloadData()
        scrollToBottom()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "채팅봇"
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

