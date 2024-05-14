import Foundation
import MusicKit
import os.log

protocol PlaylistCriteria {
    /// The prompt to be used for the OpenAI request
    func toPrompt() -> String
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
    
    func fetchPlaylistSuggestion(
        criteria: PlaylistCriteria,
        progressHandler: ((Int) -> Void)? = nil
    ) async throws -> [DBSongMetadata] {
        logger.info("Starting fetchPlaylistSuggestion with criteria: \(criteria.toPrompt())")
        
        guard let apiKey = openAIKey else {
            logger.error("Missing API key")
            throw PlaylistGeneratorError.missingAPIKey
        }
        
        let openAIPrompt = buildOpenAIPrompt(with: criteria)
        
#if targetEnvironment(simulator) && os(iOS)
        let simulatedResponse = "\n\n1. \"Only Girl (In the World)\" – Rihanna\n2. \"Dynamite\" – Taio Cruz"
        return try await metadataParser.parse(
            from: simulatedResponse,
            playlistID: UUID().uuidString,
            progressHandler: progressHandler
        )
#else
        let endpoint = GPTEndpoint(
            model: "gpt-3.5-turbo-instruct" ,
            prompt: openAIPrompt,
            maxTokens: 500,
            apiKey: apiKey
        )
        do {
            let response: GPTResponse = try await networkService.request(endpoint)
            guard let firstChoice = response.choices.first else {
                logger.error("No choices found in response")
                throw PlaylistGeneratorError.invalidResponse
            }
            return try await metadataParser.parse(
                from: firstChoice.text,
                playlistID: UUID().uuidString,
                progressHandler: progressHandler
            )
        } catch {
            logger.error("Network service error: \(error.localizedDescription)")
            throw error
        }
#endif
    }
    
    private var openAIKey: String? {
#if targetEnvironment(simulator)
        return EnvironmentItem.openAIKey.rawValue
#endif
        return ProcessInfo.processInfo.environment["API_KEY"]
    }
}

extension PlaylistGenerator {
    
    private func buildOpenAIPrompt(with criteria: PlaylistCriteria) -> String {
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
        
        let endpoint = DalleEndpoint(
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

extension PlaylistGenerator {
    /// Method to generate a playlist based on an image.
    /// Assumes an image is processed to obtain a descriptive prompt for playlist generation.
    func fetchPlaylistBasedOnImage(
        imageMessages: [VisionRequest.Message],
        progressHandler: ((Int) -> Void)? = nil
    ) async throws -> [DBSongMetadata] {
        logger.info("Starting fetchPlaylistBasedOnImage")
        
        let playlistSuggestion = try await generateVisionPlaylist(
            messages: imageMessages
        )
        
        return try await metadataParser.parse(
            from: playlistSuggestion,
            playlistID: UUID().uuidString,
            progressHandler: progressHandler
        )
    }
    
    /// Generates a playlist based on an input image.
    func generateVisionPlaylist(
        model: String = "gpt-4-vision-preview",
        messages: [VisionRequest.Message]
    ) async throws -> String {
        guard let apiKey = openAIKey else {
            logger.error("Missing API key")
            throw PlaylistGeneratorError.missingAPIKey
        }
        
#if targetEnvironment(simulator) && os(iOS)
        return """
        1. "Holocene" by Bon Iver
        2. "Skinny Love" by Birdy
        3. "River" by Leon Bridges
        4. "The Night We Met" by Lord Huron
        5. "To Build a Home" by The Cinematic Orchestra
        6. "Georgia" by Vance Joy
        7. "The A Team" by Ed Sheeran
        8. "Into the Wild" by LP
        9. "Youth" by Daughter
        10. "Heartbeats" by José González
        """
#else
        logger.info("Sending vision request to GPT")
        
        let endpoint = VisionEndpoint(
            model: model,
            messages: messages,
            apiKey: apiKey
        )
        
        do {
            let response: VisionResponse = try await networkService.request(endpoint)
            guard let description = response.choices.first?.message.content else {
                logger.error("Invalid response, missing image description.")
                throw PlaylistGeneratorError.invalidResponse
            }
            debugPrint(description)
            return description
        } catch {
            logger.error("Unknown Error: \(error.localizedDescription)")
            throw PlaylistGeneratorError.unknownError
        }
#endif
    }
}
