import Foundation
import SpotifyWebAPI
import Observation

/// This service manages:
/// - Spotify API authentication
/// - Spotify API requests
/// - Spotify API responses
/// - Spotify API errors
@Observable final class SpotifyService {
    /// The Spotify API access token.
     var accessToken: String?
    /// The Spotify API refresh token.
     var refreshToken: String?
    /// The Spotify API access token expiration date.
     var accessTokenExpirationDate: Date?
    /// The Spotify API access token is expired.
     var isAccessTokenExpired = true
    /// The Spotify API access token is refreshing.
     var isRefreshingAccessToken = false
    /// The Spotify API access token is refreshing.
     var isRefreshingRefreshToken = false
    /// The Spotify API access token is refreshing.
     var isRefreshingTokens = false
    /// The Spotify API access token is refreshing.
     var isAuthorized = false
    
    /// Authorizes the Spotify API.
    func authorize(completion: @escaping (URL) -> Void) {
        let url = URL(string: "https://accounts.spotify.com/authorize")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "scope", value: scopes.joined(separator: " "))
        ]
        completion(components.url!)
    }
    
    func exchangeCodeForToken(code: String) async throws {
        let url = URL(string: "https://accounts.spotify.com/api/token")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": redirectURI,
            "client_id": clientID,
            "client_secret": clientSecret
        ].percentEncoded()
//        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 200 {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                accessToken = json["access_token"] as? String
                refreshToken = json["refresh_token"] as? String
                accessTokenExpirationDate = Date(timeIntervalSinceNow: json["expires_in"] as! TimeInterval)
                isAccessTokenExpired = false
                isAuthorized = true
            } else {
                throw NSError(domain: "SpotifyService", code: httpResponse.statusCode, userInfo: nil)
            }
        }
    }
    
    // MARK: Private
    
    /// The Spotify API client ID.
    private var clientID: String? {
        ProcessInfo.processInfo.environment["SPOTIFY_CLIENT_ID"]
    }
    
    /// The Spotify API client secret.
    private let clientSecret = ""
    
    /// The Spotify API redirect URI.
    private let redirectURI = "vibify://spotify-login-callback"
    
    /// The Spotify API scopes.
    private let scopes = [
        "user-read-private",
        "user-read-email",
        "playlist-modify-public",
        "playlist-modify-private"
    ]
}
