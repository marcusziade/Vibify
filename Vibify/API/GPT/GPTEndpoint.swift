import Foundation

struct GPTEndpoint: Endpoint {
    
    var baseURL: URL { URL(string: "https://api.openai.com/v1")! }
    var path: String { "/completions" }
    var method: String { "POST" }
    var body: Data?
    var headers: [String: String]?
    
    init(model: String, prompt: String, maxTokens: Int, apiKey: String) {
        let bodyObject = GPTRequest(
            model: model,
            prompt: prompt,
            maxTokens: maxTokens
        )
        self.body = try? JSONEncoder().encode(bodyObject)
        
        headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]
    }
}
