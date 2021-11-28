//
//  Network.swift
//  Emotraction
//
//  Created by 김도연 on 2021/11/22.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

//json Encoding/Decoding을 위한 구조체
struct PostData: Codable {
    let text: String
}

struct EmotionData: Codable {
    let emotion: String
}

extension ViewController {
    //send 함수
    func send(message: String) {
        
        if isStart == true {
            StartOrStop(self)
        }
        
        //userList.append(message)
        messageLabel.text = "아무 말이나 해보세요"
        
        //서버통신
        guard let url = URL(string: address) else {
            alertView(message: "url이 이상합니다")
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let messageData = PostData(text: message)
        let jsonData = try? JSONEncoder().encode(messageData)
        
        request.httpBody = jsonData
        
        //url task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let _ = error {
                self.alertView(message: "network Error")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                self.alertView(message: "httpResponse Error")
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                self.alertView(message: "httpStatusCode \(httpResponse.statusCode)")
                return
            }
            
            if let data = data {
                do {
                    let resultEmotion = try JSONDecoder().decode(EmotionData.self, from: data)
                    let model = UserDefaults.standard.value(forKey: self.modelKey) as? Int ?? 0
                    var emotion = ""
                    
                    switch model {
                    case 0:
                        emotion = self.simpleModel(resultEmotion.emotion)
                    case 1:
                        emotion = self.complexModel(resultEmotion.emotion)
                    case 2:
                        self.alertView(message: "아직 준비되지 않은 모델입니다")
                        return
                    default:
                        self.alertView(message: "no Model")
                        return
                    }
                    
                    //firestore에 유저정보, 메시지, 감정을 저장하기
                    let db = Firestore.firestore()
                    let sender = Auth.auth().currentUser?.email
                    
                    db.collection("messages").addDocument(data: [
                        "sender": sender,
                        "body": message,
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
                    self.alertView(message: "data parsing Error")
                    return
                }
            }
        }
        task.resume()
    }
    
    //3가지 감정분류 모델
    func simpleModel(_ emo: String) -> String{
        switch emo {
        case "positive":
            return "😄"
        case "neutral":
            return "😑"
        case "negative":
            return "☹️"
        default:
            return "🌀"
        }
    }
    
    //7가지 감정분류 모델
    func complexModel(_ emo: String) -> String{
        switch emo {
        case "fear":
            return "😱"
        case "surprised":
            return "😮"
        case "angry":
            return "🤬"
        case "sad":
            return "😢"
        case "neutral":
            return "😑"
        case "happy":
            return "😁"
        case "disgust":
            return "🤮"
        default:
            return "🌀"
        }
    }
    
    func compelxModel2(_ emo: String) -> String{
        return ""
    }
}
