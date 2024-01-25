import Foundation

struct Engine: Codable {
    let object: String
    let id: String
    let ready: Bool
    let owner: String?
    let permissions: String?
    let created: String?
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
            created: "2020-06-11T23:22:46.474Z"
        ),
        Engine(
            object: "engine",
            id: "curie",
            ready: true,
            owner: "openai",
            permissions: "public",
            created: "2020-06-11T23:22:46.474Z"
        ),
        Engine(
            object: "engine",
            id: "babbage",
            ready: true,
            owner: "openai",
            permissions: "public",
            created: "2020-06-11T23:22:46.474Z"
        ),
        Engine(
            object: "engine",
            id: "ada",
            ready: true,
            owner: "openai",
            permissions: "public",
            created: "2020-06-11T23:22:46.474Z"
        ),
        Engine(
            object: "engine",
            id: "curie-instruct-beta",
            ready: true,
            owner: "openai",
            permissions: "public",
            created: "2020-06-11T23:22:46.474Z"
        )
    ]
}
