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
        size: String = "1024x1024",
        style: String = "vivid" // or "natural"
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
        logger.info("Prompt length: \(prompt.count)")
        
        let endpoint = DalleEndpoint(
            model: model,
            prompt: prompt,
            n: n,
            size: size,
            apiKey: apiKey,
            style: style
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
    
    func dallePrompt(forInfo info: String) async -> String {
        guard let apiKey = openAIKey else {
            logger.error("Missing API key")
            return ""
        }
        
#if targetEnvironment(simulator) && os(iOS)
        return "Doesn't matter, no dalle call is done. Cached Image is returned"
#else
        
        let promptPrefix = "Convert this output to a brief and clear PROMPT that I can use for Dalle-3 so it can generate a cool playlist cover image. Do not create an image yet; only give the prompt back to me. Don't explain anything. Make it as brief as possible while retaining the important part of the prompt:"
        
        let prompt = "\(promptPrefix) \(info)"
        
        let endpoint = GPTEndpoint(
            model: "gpt-3.5-turbo-instruct",
            prompt: prompt,
            maxTokens: 500,
            apiKey: apiKey
        )
        
        do {
            let response: GPTResponse = try await networkService.request(endpoint)
            guard let text = response.choices.first?.text else {
                logger.error("Invalid response, missing text.")
                return ""
            }
            return text.replacingOccurrences(of: "\n", with: "")
        } catch {
            logger.error("GPT-4 Text Generation error: \(error.localizedDescription)")
            return ""
        }
#endif
    }

    
    private var openAIKey: String? {
        var result: String?
#if targetEnvironment(simulator)
        result = EnvironmentItem.openAIKey.rawValue
#endif
        result = ProcessInfo.processInfo.environment["API_KEY"]
        return result
    }
}
