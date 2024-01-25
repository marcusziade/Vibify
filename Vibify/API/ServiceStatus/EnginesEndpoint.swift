import Foundation

struct EnginesEndpoint: Endpoint {
    
    var baseURL: URL { URL(string: "https://api.openai.com/v1")! }
    var path: String { "/engines" }
    var method: String { "GET" }
    var body: Data?
    var headers: [String: String]?
    
    init(apiKey: String) {
        headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]
    }
}
