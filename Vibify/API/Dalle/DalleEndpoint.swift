import Foundation

struct DalleGenerationEndpoint: Endpoint {
    var baseURL: URL { URL(string: "https://api.openai.com/v1")! }
    var path: String { "/images/generations" }
    var method: String { "POST" }
    var body: Data?
    var headers: [String: String]?
    
    init(model: String, prompt: String, n: Int, size: String, apiKey: String) {
        let bodyObject = DalleRequest(
            model: model,
            prompt: prompt,
            n: n,
            size: apiKey
        )
        body = try? JSONEncoder().encode(bodyObject)
        headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]
    }
}
