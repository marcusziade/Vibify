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
    
    var urlRequest: URLRequest? {
        guard let url = URL(string: path, relativeTo: baseURL) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        headers?.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        return request
    }
}
