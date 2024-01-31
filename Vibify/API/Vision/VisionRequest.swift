import Foundation

struct VisionRequest: Codable {
    let model: String
    let messages: [Message]
    
    struct Message: Codable {
        let role: String
        let content: [Content]
        
        struct Content: Codable {
            let type: String
            let text: String?
            let imageURL: URL?
            let base64Image: String?
            
            enum CodingKeys: String, CodingKey {
                case type, text
                case imageURL = "image_url"
                case base64Image = "base64_image"
            }
        }
    }
}
