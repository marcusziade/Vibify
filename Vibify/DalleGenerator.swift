import Foundation
import os.log

enum DalleGeneratorError: Error {
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

// Custom error for network service (replace with your actual error type)
struct DalleGeneratorPromptError: Error {
    let message: String
    let code: Int?
}

final class DalleGenerator {
    private let networkService: NetworkService
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Networking")
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    /// Generate an image from a prompt.
    func image(
        prompt: String,
        model: String = "dall-e-3",
        n: Int = 1,
        size: String = "1024x1024"
    ) async throws -> URL {
        guard let apiKey = openAIKey else {
            logger.error("Missing API key")
            throw DalleGeneratorError.missingAPIKey
        }
        
#if targetEnvironment(simulator) && os(iOS)
        let cachedImageURL = Bundle.main.url(
            forResource: "dalle-sample",
            withExtension: "png"
        )!
        return cachedImageURL
#else
        // log the prompt and how many characters it contains
        logger.info("Prompt length: \(prompt.count)")
        
        let endpoint = DalleEndpoint(
            model: model,
            prompt: prompt,
            n: n,
            size: size,
            apiKey: apiKey
        )
        
        do {
            let response: DalleGenerationResponse = try await networkService.request(endpoint)
            guard let url = response.data.first?.url else {
                logger.error("Invalid response, missing image URL.")
                throw DalleGeneratorError.invalidURL
            }
            return url
        } catch let error as DalleGeneratorPromptError {
            if error.message.contains("is too long") {
                logger.error("Prompt is too long for DALL-E Generation")
                throw DalleGeneratorError.promptTooLong
            } else if error.code == nil {
                logger.error("DALL-E Image Generation error: \(error.message)")
                throw DalleGeneratorError.promptTooLong
            } else {
                logger.error("DALL-E Image Generation error code: \(error.code!)")
                throw DalleGeneratorError.unknownError
            }
        } catch {
            logger.error("DALL-E Image Generation error: \(error.localizedDescription)")
            throw error
        }
#endif
    }
    
    private var openAIKey: String? {
        ProcessInfo.processInfo.environment["API_KEY"]
    }
}
