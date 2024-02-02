import Foundation

struct VisionRequest: Codable {
    let model: String
    let messages: [Message]
    let maxTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case model, messages
        case maxTokens = "max_tokens"
    }
    
    struct Message: Codable {
        var role: String = "user"
        let content: [Content]
        
        struct Content: Codable {
            let type: String = "text"
            let text: String? = Prompts.visionPrompt
            let imageURL: URL? = nil
            let base64Image: String?
            let detail: String? = "low"
            
            enum CodingKeys: String, CodingKey {
                case type, text
                case imageURL = "image_url"
                case base64Image = "base64_image"
                case detail
            }
        }
    }
}
