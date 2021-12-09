//
//  Network.swift
//  Emotraction
//
//  Created by 김도연 on 2021/11/22.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

var modelIndex: Int = 0
var networkAddress = ""

//단일 감정 데이터를 만드는 테스트 코드
func makeSimpleData() -> Data{
    let encoder = JSONEncoder()
    let simpleEmotion = EmotionData(emotion: "happy")
    let simpleJson = try! encoder.encode(simpleEmotion)
    
    return simpleJson
}

func makeMultiData() -> Data {
    let encoder = JSONEncoder()
    let multiEmotion = MultiEmotion(labels: ["anger", "happy", "annoyance"], scores: [0.4,0.35, 0.25])
    let multiJson = try! encoder.encode(multiEmotion)
    
    return multiJson
}


extension ViewController {
    //테스트를 위한 코드
    func noNetworkTest(message: String) {
        let data: Data!
        if (0...1).contains(modelIndex) {
            data = makeSimpleData()
        } else {
            data = makeMultiData()
        }

        do {
            var emotion = [String]()
            var score = [Double]()
            
            //단일감정일 경우
            if (0...1).contains(modelIndex) {
                let resultEmotion = try JSONDecoder().decode(EmotionData.self, from: data)
                score.append(1)
                emotion.append(resultEmotion.emotion)
            }
            //다중감정일 경우
            else {
                let resultEmotion = try JSONDecoder().decode(MultiEmotion.self, from: data)
                score = resultEmotion.scores
                emotion = resultEmotion.labels
            }
            
            
            //firestore에 유저정보, 메시지, 감정을 저장하기
            let db = Firestore.firestore()
            let sender = Auth.auth().currentUser?.email
            
            db.collection("messages").addDocument(data: [
                "sender": sender,
                "body": message,
                "score": score,
                "emotion": emotion,
                "date": Date().timeIntervalSince1970
            ]) { error in
                if let e = error {
                    print(e.localizedDescription)
                } else {
                    DispatchQueue.main.async {
                        self.messageLabel.text = "아무 말이나 해보세요"
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.alertView(message: "network Error")
            }
            return
        }
        
    }
    
    //send 함수
    func send(message: String, translated: String? = nil) {
        if isStart == true { StartOrStop(self) }
        
        DispatchQueue.main.async {
            self.messageLabel.text = "아무 말이나 해보세요"
        }
        
        print(networkAddress, " 에 요청을 보내자!")
        //네트워크 없이 더미데이터로 수행하는 테스트코드입니다
        
        //from
        noNetworkTest(message: message)
        return
        //to 주석처리하고 테스트해주세요
        
        //서버통신
        guard let url = URL(string: networkAddress) else {
            DispatchQueue.main.async {
                self.alertView(message: "network Error")
                return
            }
        }
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let messageData: PostData!
        
        if translated == nil {
            messageData = PostData(text: message)
        } else {
            messageData = PostData(text: translated!)
        }
        
        let jsonData = try? JSONEncoder().encode(messageData)
        
        request.httpBody = jsonData
        
        //url task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.alertView(message: error.localizedDescription)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.alertView(message: "response error")
                }
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    self.alertView(message: "\(httpResponse.statusCode)")
                }
                return
            }
            
            if let data = data {
                do {
                    var emotion = [String]()
                    var score = [Double]()
                    
                    //단일감정일 경우
                    if (0...1).contains(modelIndex) {
                        let resultEmotion = try JSONDecoder().decode(EmotionData.self, from: data)
                        score.append(1)
                        emotion.append(resultEmotion.emotion)
                    }
                    //다중감정일 경우
                    else {
                        let resultEmotion = try JSONDecoder().decode(MultiEmotion.self, from: data)
                        score = resultEmotion.scores
                        emotion = resultEmotion.labels
                    }
                    
                    
                    //firestore에 유저정보, 메시지, 감정을 저장하기
                    let db = Firestore.firestore()
                    let sender = Auth.auth().currentUser?.email
                    
                    db.collection("messages").addDocument(data: [
                        "sender": sender,
                        "body": message,
                        "score": score,
                        "emotion": emotion,
                        "date": Date().timeIntervalSince1970
                    ]) { error in
                        if let e = error {
                            print(e.localizedDescription)
                        } else {
                            DispatchQueue.main.async {
                                self.messageLabel.text = "아무 말이나 해보세요"
                            }
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.alertView(message: "network Error")
                    }
                    return
                }
            }
        }
        task.resume()
    }
    
}
