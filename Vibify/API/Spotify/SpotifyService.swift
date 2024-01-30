import Combine
import Foundation
import KeychainAccess
import SpotifyWebAPI
import SwiftUI

@Observable final class SpotifyService {
    
    /// The authorization key stored in the Keychain
    let authorizationManagerKey = "authorizationManager"
    
    /// The URL that Spotify will redirect to after the user either authorizes or denies authorization.
    let loginCallbackURL = URL(string: "vibify://spotify-login-callback")!
    
    /// A cryptographically secure random string used to prevent CSRF attacks.
    var authorizationState: String = {
        String.randomURLSafe(length: 128)
    }()
    
    /// Checks whether the user is authorized to use the Spotify API.
    var isAuthorized = false
    
    /// Checks if the user is retrieving access and refresh tokens.
    var isRetrievingTokens = false
    
    /// The current Spotify user.
    var currentUser: SpotifyUser? = nil
    
    private(set) var keychain = Keychain(service: "com.marcusziade.Vibify.app")
    
    /// An instance of the Spotify API.
    let api = SpotifyAPI(
        authorizationManager: AuthorizationCodeFlowManager(
            clientId: clientID,
            clientSecret: clientSecret
        )
    )
    
    var authorizationURL: URL {
        let url = api.authorizationManager.makeAuthorizationURL(
            redirectURI: loginCallbackURL,
            showDialog: true,
            state: authorizationState,
            scopes: [
                .userReadPlaybackState,
                .userModifyPlaybackState,
                .playlistModifyPrivate,
                .playlistModifyPublic,
                .userLibraryRead,
                .userLibraryModify,
                .userReadRecentlyPlayed
            ]
        )!
        
        return url
    }
    
    init() {
        api.apiRequestLogger.logLevel = .trace
        
        api.authorizationManagerDidChange
            .receive(on: RunLoop.main)
            .sink(receiveValue: authorizationManagerDidChange)
            .store(in: &cancellables)
        
        api.authorizationManagerDidDeauthorize
            .receive(on: RunLoop.main)
            .sink(receiveValue: authorizationManagerDidDeauthorize)
            .store(in: &cancellables)
        
        retrieveTokensFromKeychainIfNeeded()
    }
    
    // MARK: Private
    
    private var cancellables = Set<AnyCancellable>()
    
    private static let clientID: String = {
        if let id = ProcessInfo.processInfo.environment["SPOTIFY_CLIENT_ID"] {
            return id
        } else {
            fatalError("SPOTIFY_CLIENT_ID not set")
        }
    }()
    
    private static let clientSecret: String = {
        if let secret = ProcessInfo.processInfo.environment["SPOTIFY_CLIENT_SECRET"] {
            return secret
        } else {
            fatalError("SPOTIFY_CLIENT_SECRET not set")
        }
    }()
    
    func authorizationManagerDidChange() {
        withAnimation() {
            isAuthorized = api.authorizationManager.isAuthorized()
        }
        
        debugPrint("Spotify.authorizationManagerDidChange: isAuthorized:", isAuthorized)
        
        self.retrieveCurrentUser()
        
        do {
            let authManagerData = try JSONEncoder().encode(
                api.authorizationManager
            )
            
            keychain[data: authorizationManagerKey] = authManagerData
            print("did save authorization manager to keychain")
            
        } catch {
            print(
                "couldn't encode authorizationManager for storage " +
                "in keychain:\n\(error)"
            )
        }
    }
    
    /// Removes `api.authorizationManager` from the keychain and sets `currentUser` to `nil`. This method is called every time `api.authorizationManager.deauthorize` is called.
    func authorizationManagerDidDeauthorize() {
        withAnimation() {
            isAuthorized = false
        }
        
        currentUser = nil
        
        do {
            try self.keychain.remove(self.authorizationManagerKey)
            print("did remove authorization manager from keychain")
            
        } catch {
            print(
                "couldn't remove authorization manager " +
                "from keychain: \(error)"
            )
        }
    }
    
    func retrieveCurrentUser(onlyIfNil: Bool = true) {
        if onlyIfNil && self.currentUser != nil {
            return
        }
        
        guard isAuthorized else { return }
        
        api.currentUserProfile()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("couldn't retrieve current user: \(error)")
                    }
                },
                receiveValue: { [unowned self] user in
                    currentUser = user
                }
            )
            .store(in: &cancellables)
    }
    
    private func retrieveTokensFromKeychainIfNeeded() {
        if let authManagerData = keychain[data: self.authorizationManagerKey] {
            do {
                let authorizationManager = try JSONDecoder().decode(
                    AuthorizationCodeFlowManager.self,
                    from: authManagerData
                )
                print("found authorization information in keychain")
                api.authorizationManager = authorizationManager
            } catch {
                print("could not decode authorizationManager from data:\n\(error)")
            }
        } else {
            print("did NOT find authorization information in keychain")
        }
    }
}
