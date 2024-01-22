import Foundation

final class SpotifyManager {
    private let clientId: String
    private let clientSecret: String
    private var accessToken: String?
    
    init(clientId: String, clientSecret: String) {
        self.clientId = clientId
        self.clientSecret = clientSecret
    }
    
    func authenticate(completion: @escaping (Bool) -> Void) {
        let url = URL(string: "https://accounts.spotify.com/api/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let body = "grant_type=client_credentials".data(using: .utf8)!
        request.httpBody = body
        
        let authValue = "\(clientId):\(clientSecret)".data(using: .utf8)!.base64EncodedString()
        request.addValue("Basic \(authValue)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [unowned self] data, response, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            
            if
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let token = json["access_token"] as? String
            {
                accessToken = token
                completion(true)
            } else {
                completion(false)
            }
        }
        task.resume()
    }
    
    func getAccessToken() -> String? {
        return accessToken
    }
}
