import Foundation

struct DalleGenerationResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let generations: [Generation]
    
    struct Generation: Codable {
        let id: String
        let object: String
        let created: Int
        let prompt: Prompt
        let image_path: String
        let status: String
    }
    
    struct Prompt: Codable {
        let id: String
        let object: String
        let created: Int
        let prompt: String
    }
}
