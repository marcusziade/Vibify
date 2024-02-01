import Foundation
import os.log

enum VisionGeneratorError: Error {
    case missingAPIKey
    case invalidRequest
    case unexpectedStatusCode(Int)
    case networkFailure
    case dataDecodingError(Error)
    case serverError
    case unknownError
    case invalidResponse
    case invalidURL
    case promptTooLong
}

struct VisionGeneratorPromptError: Error {
    let message: String
    let code: Int?
}

final class VisionGenerator {
    private let networkService: NetworkService
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: "Networking"
    )
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    /// Generate a description of an image from a prompt.
    func describeImage(
        model: String = "gpt-4-vision-preview",
        messages: [VisionRequest.Message]
    ) async throws -> String {
        guard let apiKey = openAIKey else {
            logger.error("Missing API key")
            throw VisionGeneratorError.missingAPIKey
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
                throw VisionGeneratorError.invalidResponse
            }
            debugPrint(description)
            return description
        } catch {
            logger.error("Unknown Error: \(error.localizedDescription)")
            throw PlaylistGeneratorError.unknownError
        }
#endif
    }
    
    private var openAIKey: String? {
        ProcessInfo.processInfo.environment["API_KEY"]
    }
}
