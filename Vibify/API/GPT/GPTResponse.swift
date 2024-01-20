import Foundation

struct GPTResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let text: String
    }
}
