import Foundation

struct DalleGenerationResponse: Codable {
    let created: Int
    let data: [Generation]
    
    struct Generation: Codable {
        let url: URL
    }
}
