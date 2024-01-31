import Foundation

struct VisionResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: VisionRequest.Message
    }
}
