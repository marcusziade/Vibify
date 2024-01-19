import Foundation

struct GPTEndpoint: Endpoint {
    var baseURL: URL { URL(string: "https://api.openai.com/v1")! }
    var path: String { "/completions" }
    var method: String { "POST" }
    var body: Data?
    
    init(prompt: String, maxTokens: Int) {
        let bodyObject = OpenAIRequest(model: "gpt-3.5-turbo-instruct", prompt: prompt, maxTokens: maxTokens)
        self.body = try? JSONEncoder().encode(bodyObject)
    }
}
