//
//  Model.swift
//  Emotraction
//
//  Created by 김도연 on 2021/11/27.
//

import Foundation

let emotionDict : [String:String] = [
    //goemotions 28
    "admiration": "감탄",
    "amusement": "재미",
    "anger": "분노",
    "annoyance": "짜증",
    "approval": "인정",
    "caring": "배려",
    "confusion": "혼란",
    "curiosity": "호기심",
    "desire": "욕망",
    "disappointment": "실망",
    "disapproval": "반감",
    "disgust": "혐오",
    "embarrassment": "곤란",
    "excitement": "흥분",
    "fear": "공포",
    "gratitude": "감사",
    "grief": "비탄",
    "joy": "기쁨",
    "love": "사랑",
    "nervousness": "긴장",
    "optimism": "낙관",
    "pride": "자부심",
    "realization": "깨달음",
    "relief": "안도",
    "remorse": "후회",
    "sadness": "슬픔",
    "surprise": "놀람",
    "neutral": "부정",
    "ambiguous": "애매",
    "positive": "긍정",
    "negative": "부정",
    // korean model
    "surprised": "놀람",
    "sad": "슬픔",
    "happy": "행복",
]

struct Message {
    let sender: String
    let body: String
    let emotion: [String]
    let score: [Double]
}

//json Encoding/Decoding을 위한 구조체
struct PostData: Codable {
    let text: String
}

struct EmotionData: Codable {
    let emotion: String
}


//다중감정을 위한 구조체
struct MultiEmotion: Codable {
    let labels: [String]
    let scores: [Double]
}


//papago 번역을 위한 Model

struct PapagoResult: Codable {
    let translatedText: String
}

struct PapagoMessage: Codable {
    let type: String
    let service: String
    let version: String
    let result: PapagoResult
    
    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case service = "@service"
        case version = "@version"
        case result
    }
}

struct Papago: Codable {
    let message: PapagoMessage
}
