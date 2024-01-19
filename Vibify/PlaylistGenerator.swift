import Foundation
import MusicKit
import os.log

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
    case invalidRequest
    case unexpectedStatusCode(Int)
    case serverError
    case networkFailure
    case unknownError
}

final class PlaylistGenerator {
    private let networkService: NetworkService
    private let metadataParser: DBSongMetadataParser
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Networking")
    
    init(networkService: NetworkService) {
        self.networkService = networkService
        self.metadataParser = DBSongMetadataParser(logger: logger)
    }
    
    func fetchPlaylistSuggestion(criteria: SongSearchCriteria, progressHandler: ((Int) -> Void)? = nil) async throws -> [DBSongMetadata] {
        logger.info("Starting fetchPlaylistSuggestion with criteria: \(criteria.toPrompt())")
        
        guard let apiKey = openAIKey else {
            logger.error("Missing API key")
            throw PlaylistGeneratorError.missingAPIKey
        }
        
        let openAIPrompt = buildOpenAIPrompt(with: criteria)
        
#if targetEnvironment(simulator) && os(iOS)
        let simulatedResponse = "\n\n1. \"Only Girl (In the World)\" – Rihanna\n2. \"Dynamite\" – Taio Cruz"
        return try await metadataParser.parse(from: simulatedResponse, playlistID: UUID().uuidString, progressHandler: progressHandler)
#else
        let endpoint = GPTEndpoint(prompt: openAIPrompt, maxTokens: 500, apiKey: apiKey)
        do {
            let response: OpenAIResponse = try await networkService.request(endpoint)
            guard let firstChoice = response.choices.first else {
                logger.error("No choices found in response")
                throw PlaylistGeneratorError.invalidResponse
            }
            return try await metadataParser.parse(from: firstChoice.text, playlistID: UUID().uuidString, progressHandler: progressHandler)
        } catch {
            logger.error("Network service error: \(error.localizedDescription)")
            throw error
        }
#endif
    }
    
    private var openAIKey: String? {
        ProcessInfo.processInfo.environment["API_KEY"]
    }
}

extension PlaylistGenerator {
    
    private func buildOpenAIPrompt(with criteria: SongSearchCriteria) -> String {
        let defaultInstructions = "Generate a playlist and number the result based on the following criteria. Only list out the songs. Don't explain anything:"
        let criteriaPrompt = criteria.toPrompt()
        let combinedPrompt = "\(defaultInstructions)\n\n\(criteriaPrompt)"
        return combinedPrompt
    }
}

extension PlaylistGenerator {
    
    func generateImageWithDalle(
        prompt: String,
        model: String = "dall-e-3",
        n: Int = 1,
        size: String = "1024x1024"
    ) async throws -> DalleGenerationResponse {
        guard let apiKey = openAIKey else {
            logger.error("Missing API key")
            throw PlaylistGeneratorError.missingAPIKey
        }
        
        let endpoint = DalleGenerationEndpoint(
            model: model,
            prompt: prompt,
            n: n,
            size: size,
            apiKey: apiKey
        )
        
        do {
            let response: DalleGenerationResponse = try await networkService.request(endpoint)
            return response
        } catch {
            logger.error("DALL-E Image Generation error: \(error.localizedDescription)")
            throw error
        }
    }
}
