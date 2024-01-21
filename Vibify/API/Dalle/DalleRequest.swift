import Foundation

struct DalleRequest: Codable {
    let model: String
    let prompt: String
    let n: Int?
    let size: String?
    let quality: String?
    let responseFormat: String?
    let style: String?
    let user: String?
    
    enum CodingKeys: String, CodingKey {
        case model, prompt, n, size, quality, style, user
        case responseFormat = "response_format"
    }
}
