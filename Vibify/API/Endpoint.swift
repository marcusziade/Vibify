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
        guard let url = URL(string: path, relativeTo: baseURL) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        headers?.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        return request
    }
}
