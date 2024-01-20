import Foundation

protocol Endpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: String { get }
    var body: Data? { get }
    var headers: [String: String]? { get }
    
    var urlRequest: URLRequest? { get }
}

extension Endpoint {
    
    var urlRequest: URLRequest? {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = method
        request.httpBody = body
        headers?.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        return request
    }
}
