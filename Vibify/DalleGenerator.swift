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
        
        let endpoint = DalleGenerationEndpoint(
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
        } catch {
            logger.error("DALL-E Image Generation error: \(error.localizedDescription)")
            throw error
        }
    }
    
    private var openAIKey: String? {
        ProcessInfo.processInfo.environment["API_KEY"]
    }
}
