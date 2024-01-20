import Foundation

struct GPTRequest: Codable {
    let model: String
    let prompt: String
    let maxTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case model
        case prompt
        case maxTokens = "max_tokens"
    }
}
