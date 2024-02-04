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
            /// By controlling the detail parameter, which has three options, `low`, `high`, or `auto`,
            /// you have control over how the model processes the image and generates its textual understanding.
            /// By default, the model will use the `auto` setting which will look at the image input size and decide if it should use the `low` or `high` setting.
            let detail: String? = "auto"
            
            enum CodingKeys: String, CodingKey {
                case type, text
                case imageURL = "image_url"
                case base64Image = "base64_image"
                case detail
            }
        }
    }
}
