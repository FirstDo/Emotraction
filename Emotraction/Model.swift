//
//  Model.swift
//  Emotraction
//
//  Created by 김도연 on 2021/11/27.
//

import Foundation

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
