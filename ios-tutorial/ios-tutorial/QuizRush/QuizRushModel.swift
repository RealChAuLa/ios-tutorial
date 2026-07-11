//
//  Model.swift
//  ios-tutorial
//
//  Created by Student3 on 2026-06-28.
//
import Foundation

// MARK: - Configuration Enums
enum TriviaDifficulty: String, CaseIterable, Identifiable {
    case any, easy, medium, hard
    var id: String { rawValue }
    var label: String { rawValue.capitalized }
}

enum TriviaType: String, CaseIterable, Identifiable {
    case any
    case multiple
    case boolean
    var id: String { rawValue }
    var label: String {
        switch self {
        case .any:      return "Any Type"
        case .multiple: return "Multiple Choice"
        case .boolean:  return "True / False"
        }
    }
}

enum TriviaCategory: Int, CaseIterable, Identifiable {
    case any = 0
    case generalKnowledge = 9
    case books = 10
    case film = 11
    case music = 12
    case musicalsTheatres = 13
    case television = 14
    case videoGames = 15
    case boardGames = 16
    case scienceNature = 17
    case computers = 18
    case mathematics = 19
    case mythology = 20
    case sports = 21
    case geography = 22
    case history = 23
    case politics = 24
    case art = 25
    case celebrities = 26
    case animals = 27
    case vehicles = 28
    case comics = 29
    case gadgets = 30
    case anime = 31
    case cartoons = 32

    var id: Int { rawValue }
    var label: String {
        switch self {
        case .any: return "Any Category"
        case .generalKnowledge: return "General Knowledge"
        case .books: return "Books"
        case .film: return "Film"
        case .music: return "Music"
        case .musicalsTheatres: return "Musicals & Theatres"
        case .television: return "Television"
        case .videoGames: return "Video Games"
        case .boardGames: return "Board Games"
        case .scienceNature: return "Science & Nature"
        case .computers: return "Computers"
        case .mathematics: return "Mathematics"
        case .mythology: return "Mythology"
        case .sports: return "Sports"
        case .geography: return "Geography"
        case .history: return "History"
        case .politics: return "Politics"
        case .art: return "Art"
        case .celebrities: return "Celebrities"
        case .animals: return "Animals"
        case .vehicles: return "Vehicles"
        case .comics: return "Comics"
        case .gadgets: return "Gadgets"
        case .anime: return "Anime & Manga"
        case .cartoons: return "Cartoon & Animations"
        }
    }
}

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
