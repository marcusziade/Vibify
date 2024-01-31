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
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Networking")
    
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
        return "Simulated response for image description."
#else
        logger.info("Sending vision request to GPT")
        
        let endpoint = VisionEndpoint(
            model: model,
            messages: messages,
            apiKey: apiKey
        )
        
        do {
            let response: VisionResponse = try await networkService.request(endpoint)
            guard let description = response.choices.first?.message.content.first(where: { $0.type == "text" })?.text else {
                logger.error("Invalid response, missing image description.")
                throw GPTVisionGeneratorError.invalidResponse
            }
            return description
        } catch let error as? GPTVisionGeneratorPromptError {
            // Handle custom error
        } catch {
            logger.error("GPT Vision Generation error: \(error.localizedDescription)")
            throw error
        }
#endif
    }
    
    private var openAIKey: String? {
        ProcessInfo.processInfo.environment["API_KEY"]
    }
}
