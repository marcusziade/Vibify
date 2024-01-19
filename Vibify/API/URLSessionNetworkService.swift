import Foundation

protocol NetworkService {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

class URLSessionNetworkService: NetworkService {
    func request<T>(_ endpoint: Endpoint) async throws -> T where T: Decodable {
        guard let urlRequest = endpoint.urlRequest else {
            throw PlaylistGeneratorError.invalidRequest
        }
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PlaylistGeneratorError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            // Handle different status codes accordingly
            #warning("Network error here")
            throw PlaylistGeneratorError.unexpectedStatusCode(httpResponse.statusCode)
        }
        
        do {
            let decodedResponse = try JSONDecoder().decode(T.self, from: data)
            return decodedResponse
        } catch {
            throw PlaylistGeneratorError.dataDecodingError(error)
        }
    }
}
