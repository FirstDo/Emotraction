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
import Charts

class ViewController: UIViewController {

    @IBOutlet weak var chartView: HorizontalBarChartView!
    
    //MARK: - OUTLET
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var AppleButton: UIButton!
    
    var messageList = [Message]()
    
    let simple3 = "http://163.239.28.25:5000/three"
    let simple7 = "http://163.239.28.25:5000/seven"
    
    let multi27 = "http://192.168.0.17:5000/original"
    let multi7 = "http://192.168.0.17:5000/ekman"
    let multi3 = "http://192.168.0.17:5000/group"
    


    //MARK: - apple Speech to Text
    //소리만을 인식하는 오디오 엔진객체
    let audioEngine = AVAudioEngine()
    //음성인식기
    let speechReconizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale(identifier: "ko_KR"))
    //음성인식요청을 처리하는 객체
    let request = SFSpeechAudioBufferRecognitionRequest()
    //인식요청결과를 제공하는 객체
    var task: SFSpeechRecognitionTask!
    var isStart: Bool = false
    
    @IBAction func SelectModel(_ sender: UISegmentedControl) {
         modelIndex = sender.selectedSegmentIndex
        
        var modelName = ""
        var message = ""
        
        switch modelIndex {
        case 0:
            modelName = "3가지 단일 감정분류 모델"
            message = "서버에서 NewEmotion.py 를 실행해주세요"
            networkAddress = simple3
        case 1:
            modelName = "7가지 단일 감정분류 모델"
            message = "서버에서 TestEmotion.py 를 실행해주세요"
            networkAddress = simple7
        case 2:
            modelName = "3가지 다중 감정분류 모델"
            message = "서버에서.. "
            networkAddress = multi3
        case 3:
            modelName = "7가지 다중 감정분류 모델"
            message = "서버에서.. "
            networkAddress = multi7
            
        case 4:
            modelName = "27가지 다중 감정분류 모델"
            message = "서버에서.. "
            networkAddress = multi27
        default:
            break
        }
        alertView(message: message, title: modelName)
    }
    
    
    @IBAction func StartOrStop(_ sender: Any) {
        isStart = !isStart
        
        if isStart {
            DispatchQueue.main.async {
                self.stateLabel.text = "Recording..."
                self.stateLabel.textColor = .systemRed
                self.AppleButton.tintColor = .systemRed
            }
            startSpeechRecognization()
        } else {
            DispatchQueue.main.async {
                self.stateLabel.text = "Waiting..."
                self.stateLabel.textColor = .black
                self.AppleButton.tintColor = .black
            }
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
        
        if (2...4).contains(modelIndex) {
            print("다중감정 모델! 영어번역이 필요하다.")
            callPapago(message)
        } else {
            send(message: message)
        }
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
        networkAddress = simple3
        alertView(message: "서버에서 NewEmotion.py를 선택해주세요", title: "3가지 감정분류 모델")
        
        //chartView
        
        
        chartView.noDataText = "감정 데이터가 없습니다"
        chartView.noDataFont = .systemFont(ofSize: 20)
        chartView.noDataTextColor = .lightGray
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
                        if let sender = data["sender"] as? String, let body = data["body"] as? String, let emotion = data["emotion"] as? [String], let score = data["score"] as? [Double] {
                            self.messageList.append(Message(sender: sender, body: body, emotion: emotion, score: score))

                        }
                    }
                    
                    
                    if let target = self.messageList.filter({$0.sender != Auth.auth().currentUser?.email}).last {
                        print(target, "내 메시지가 아닌것만 뽑아오자")
                        
                        let emotionList = target.emotion.map{emotionDict[$0]!}
                        let unitScore = target.score.map{100*$0}
                        
                        self.setChart(dataPoints: emotionList, values: unitScore)
                    }
                               
                    DispatchQueue.main.async {
                        self.chatTableView.reloadData()
                        self.scrollToBottom()
                    }
                }
            }
        }
    }
    
    //drawChart
    func setChart(dataPoints: [String], values: [Double]) {
        var dataEntries: [BarChartDataEntry] = []

        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }

        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "")
        chartDataSet.colors = ChartColorTemplates.joyful()
        
        let chartData = BarChartData(dataSet: chartDataSet)
        chartView.data = chartData

        
        //xAxis
        let xAxis = chartView.xAxis
        
        xAxis.drawGridLinesEnabled = false
        xAxis.labelPosition = .bottomInside
        
        xAxis.centerAxisLabelsEnabled = false
        xAxis.granularity = 1
        xAxis.granularityEnabled = true
        xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
        
        chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)

        xAxis.setLabelCount(dataPoints.count, force: false)
        xAxis.labelFont = .systemFont(ofSize: 20)
       
        chartView.rightAxis.enabled = false
        chartView.doubleTapToZoomEnabled = false
        
        chartView.leftAxis.axisMinimum = 0
        //chartView.leftAxis.axisMaximum = values.first! + 10
        
 
    }
    
    //call Papago
    func callPapago(_ text: String) {
        let param = "source=ko&target=en&text=\(text)"
        let paramData = param.data(using: .utf8)
        guard let naverURL = URL(string: "https://openapi.naver.com/v1/papago/n2mt") else {
            alertView(message: "naver URL 생성 실패")
            return
        }
        
        let clientID = "gTG6myOpwpwExEFvXBrg"
        let clientSecret = "D1nNT3Otyt"
        
        //request
        var request = URLRequest(url: naverURL)
        request.httpMethod = "POST"
        request.addValue(clientID, forHTTPHeaderField: "X-Naver-Client-ID")
        request.addValue(clientSecret, forHTTPHeaderField: "X-Naver-Client-Secret")
        request.httpBody = paramData
        request.setValue(String(paramData!.count), forHTTPHeaderField: "Content-Length")
        
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let data = data {
                let result = try! JSONDecoder().decode(Papago.self, from: data)
                let translatedMessage = result.message.result.translatedText
                self.send(message: text, translated: translatedMessage)
                
            }
        }
        task.resume()
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
            cell.emotion.text = nil
            return cell
        }
    }
}

