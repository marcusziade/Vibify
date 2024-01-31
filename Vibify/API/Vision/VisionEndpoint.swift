import Foundation

struct VisionEndpoint: Endpoint {
    var baseURL: URL { URL(string: "https://api.openai.com/v1")! }
    var path: String { "/chat/completions" }
    var method: String { "POST" }
    var body: Data?
    var headers: [String: String]?
    
    init(
        model: String,
        messages: [VisionRequest.Message],
        apiKey: String
    ) {
        let bodyObject = VisionRequest(
            model: model,
            messages: messages
        )
        body = try? JSONEncoder().encode(bodyObject)
        headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]
    }
}
