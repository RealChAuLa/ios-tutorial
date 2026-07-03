//
//  Model.swift
//  ios-tutorial
//
//  Created by Student3 on 2026-06-28.
//
import Foundation

// Changed from Codable to Decodable since we only read data, not send it
struct TriviaResponse: Decodable {
    let results: [TriviaQuestion]
}

struct TriviaQuestion: Decodable {
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    
    enum CodingKeys: String, CodingKey {
        case question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
    
    // Custom decoder initializer to clean the strings the moment they arrive
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let rawQuestion = try container.decode(String.self, forKey: .question)
        self.question = rawQuestion.replacingHTMLEntities()
        
        let rawCorrectAnswer = try container.decode(String.self, forKey: .correctAnswer)
        self.correctAnswer = rawCorrectAnswer.replacingHTMLEntities()
        
        let rawIncorrectAnswers = try container.decode([String].self, forKey: .incorrectAnswers)
        self.incorrectAnswers = rawIncorrectAnswers.map { $0.replacingHTMLEntities() }
    }
}

// Your extension stays exactly the same
extension String {
    func replacingHTMLEntities() -> String {
        return self
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#039;", with: "'")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
    }
}
