import Foundation

struct Engine: Codable {
    let object: String
    let id: String
    let ready: Bool
    let owner: String?
    let permissions: String?
    let created: Date?
}

// MARK: Mock

extension Engine {
    
    /// Mocks 5 Open AI engines
    static let mocks: [Engine] = [
        Engine(
            object: "engine",
            id: "davinci",
            ready: true,
            owner: "openai",
            permissions: "public",
            created: Date()
        ),
        Engine(
            object: "engine",
            id: "curie",
            ready: true,
            owner: "openai",
            permissions: "public",
            created: Date()
        ),
        Engine(
            object: "engine",
            id: "babbage",
            ready: true,
            owner: "openai",
            permissions: "public",
            created: Date()
        ),
        Engine(
            object: "engine",
            id: "ada",
            ready: true,
            owner: "openai",
            permissions: "public",
            created: Date()
        ),
        Engine(
            object: "engine",
            id: "curie-instruct-beta",
            ready: true,
            owner: "openai",
            permissions: "public",
            created: Date()
        )
    ]
}
