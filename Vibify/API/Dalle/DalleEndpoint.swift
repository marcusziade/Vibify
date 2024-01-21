import Foundation

struct DalleGenerationEndpoint: Endpoint {
    var baseURL: URL { URL(string: "https://api.openai.com/v1")! }
    var path: String { "/images/generations" }
    var method: String { "POST" }
    var body: Data?
    var headers: [String: String]?
    
    init(
        model: String,
        prompt: String,
        n: Int?,
        size: String?,
        apiKey: String,
        quality: String? = nil,
        responseFormat: String? = nil,
        style: String? = nil,
        user: String? = nil
    ) {
        let bodyObject = DalleRequest(
            model: model,
            prompt: prompt,
            n: n,
            size: size,
            quality: quality,
            responseFormat: responseFormat,
            style: style,
            user: user
        )
        body = try? JSONEncoder().encode(bodyObject)
        headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]
    }
}
