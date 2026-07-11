import Foundation

struct TriviaService {
    func fetchQuestions(
        amount: Int = 10,
        category: TriviaCategory = .any,
        difficulty: TriviaDifficulty = .any,
        type: TriviaType = .any
    ) async throws -> [TriviaQuestion] {
        var components = URLComponents(string: "https://opentdb.com/api.php")!
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "amount", value: "\(amount)")
        ]
        if category != .any {
            queryItems.append(URLQueryItem(name: "category", value: "\(category.rawValue)"))
        }
        if difficulty != .any {
            queryItems.append(URLQueryItem(name: "difficulty", value: difficulty.rawValue))
        }
        if type != .any {
            queryItems.append(URLQueryItem(name: "type", value: type.rawValue))
        }
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        // async/await URLSession call
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // Decode the raw JSON data to response struct
        let decodedResponse = try JSONDecoder().decode(TriviaResponse.self, from: data)
        
        return decodedResponse.results
    }
}
