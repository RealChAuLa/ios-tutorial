import Foundation

struct TriviaService {
    private let urlString = "https://opentdb.com/api.php?amount=10&type=multiple"
    
    func fetchQuestions() async throws -> [TriviaQuestion] {
        guard let url = URL(string: urlString) else {
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
