import Foundation

struct OpenAIResponse: Codable {
    let text: String
}

final class PlaylistGenerator {
    
    func fetchPlaylistSuggestion(prompt: String) async throws -> String {
        let url = URL(string: "https://api.openai.com/v1/engines/text-davinci-004/completions")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let requestBody: [String: Any] = [
            "prompt": prompt,
            "max_tokens": 100
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decodedResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        return decodedResponse.text
    }
    
    private let apiKey = "YOUR_OPENAI_API_KEY"
}
