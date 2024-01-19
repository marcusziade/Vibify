import Foundation

protocol Endpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: String { get }
    var body: Data? { get }
    
    var urlRequest: URLRequest? { get }
}

extension Endpoint {
    var urlRequest: URLRequest? {
        guard let url = URL(string: path, relativeTo: baseURL) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        // Add additional common headers if necessary
        return request
    }
}
