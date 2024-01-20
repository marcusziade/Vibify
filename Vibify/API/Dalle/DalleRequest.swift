import Foundation

struct DalleRequest: Codable {
    let model: String
    let prompt: String
    let n: Int
    let size: String
}
