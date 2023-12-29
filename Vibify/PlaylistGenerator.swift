import Foundation

struct OpenAIRequest: Codable {
    let model: String
    let prompt: String
    let maxTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case model
        case prompt
        case maxTokens = "max_tokens"
    }
}

struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let text: String
    }
}

enum PlaylistGeneratorError: Error {
    case urlSessionError(Error)
    case dataDecodingError(Error)
    case invalidResponse
    case unauthorized
    case rateLimitExceeded
    case missingAPIKey
}

final class PlaylistGenerator {
    
    private var openAIKey: String {
        ProcessInfo.processInfo.environment["OPENAI_KEY"] ?? ""
    }
    
    func fetchPlaylistSuggestion(prompt: String) async throws -> [String] {
        guard !openAIKey.isEmpty else {
            throw PlaylistGeneratorError.missingAPIKey
        }
        
#if targetEnvironment(simulator)
        return parseSongTitles(from: "\n\n1. Blah Blah Blah - Ke$ha \n2. Club Can\'t Handle Me - Flo Rida ft. David Guetta \n3. Tik Tok - Ke$ha")
#else
        guard let url = URL(string: "https://api.openai.com/v1/completions") else {
            throw PlaylistGeneratorError.invalidResponse
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(openAIKey)", forHTTPHeaderField: "Authorization")
        
        let body = OpenAIRequest(model: "text-davinci-003", prompt: prompt, maxTokens: 100)
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            debugPrint("JSON Serialization Error: \(error)")
            throw PlaylistGeneratorError.dataDecodingError(error)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                debugPrint("Invalid response")
                throw PlaylistGeneratorError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200:
                do {
                    let decodedResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                    guard let firstChoice = decodedResponse.choices.first else {
                        throw PlaylistGeneratorError.invalidResponse
                    }
                    return parseSongTitles(from: firstChoice.text)
                } catch {
                    debugPrint("Error decoding response: \(error)")
                    throw PlaylistGeneratorError.dataDecodingError(error)
                }
            case 401:
                debugPrint("Unauthorized: Invalid API Key")
                throw PlaylistGeneratorError.unauthorized
            case 429:
                debugPrint("Rate limit exceeded")
                throw PlaylistGeneratorError.rateLimitExceeded
            default:
                debugPrint("Invalid status code: \(httpResponse.statusCode)")
                throw PlaylistGeneratorError.invalidResponse
            }
        } catch {
            debugPrint("URL Session error: \(error)")
            throw PlaylistGeneratorError.urlSessionError(error)
        }
#endif
    }
    
    private func parseSongTitles(from playlistString: String) -> [String] {
        // Split the string into lines
        let lines = playlistString.components(separatedBy: .newlines)
        
        // Extract the song titles and artists
        let songTitles = lines.compactMap { line -> String? in
            // Look for the pattern "number. title - artist"
            let components = line.split(separator: ".")
                .map { $0.trimmingCharacters(in: .whitespaces) }
            
            guard components.count >= 2 else { return nil }
            
            // The song title and artist are after the period
            let titleArtistPart = components.dropFirst().joined(separator: ".")
            
            // Further split to isolate the title if needed
            let titleArtistComponents = titleArtistPart.split(separator: "-")
                .map { $0.trimmingCharacters(in: .whitespaces) }
            
            // Here we return the full title with artist as it increases the chance to match the correct song in Apple Music
            return titleArtistComponents.joined(separator: " - ")
        }
        
        return songTitles
    }
}
