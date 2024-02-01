import Combine
import SpotifyWebAPI
import SwiftUI

@main
struct VibifyApp: App {
    
    @State private var spotify = SpotifyService()
    @State private var alert: AlertItem? = nil
    @State private var cancellables: Set<AnyCancellable> = []
    
    init() {
        SpotifyAPILogHandler.bootstrap()
    }
    
    var body: some Scene {
        WindowGroup {
            VisionGeneratorView()
//            PlaylistGeneratorView(viewModel: initialize())
//                .environment(spotify)
//                .alert(item: $alert) { alert in
//                    Alert(title: alert.title, message: alert.message)
//                }
//                .onOpenURL(perform: handleURL)
        }
    }
}

private extension VibifyApp {
    
    func initialize() -> PlaylistGeneratorVM {
        let networkService = URLSessionNetworkService()
        let playlistGenerator = PlaylistGeneratorVM(
            networkService: networkService,
            databaseManager: DatabaseManager(),
            playlistGenerator: PlaylistGenerator(networkService: networkService),
            appleMusicImporter: AppleMusicImporter(),
            dalleGenerator: DalleGenerator(networkService: networkService)
        )
        return playlistGenerator
    }
    
    /// Handle the URL that Spotify redirects to after the user Either authorizes or denies authorization for the application.
    /// - Warning: The simulator crashes with this.
    /// - Note: Arc Browse browser (released 2024) doesn't support callback URLs.
    func handleURL(_ url: URL) {
        guard url.scheme == spotify.loginCallbackURL.scheme else {
            print("not handling URL: unexpected scheme: '\(url)'")
            alert = AlertItem(
                title: "Cannot Handle Redirect",
                message: "Unexpected URL"
            )
            return
        }
        
        print("received redirect from Spotify: '\(url)'")
        
        spotify.isRetrievingTokens = true
        
        spotify.api.authorizationManager.requestAccessAndRefreshTokens(
            redirectURIWithQuery: url,
            state: spotify.authorizationState
        )
        .receive(on: RunLoop.main)
        .sink(receiveCompletion: { completion in
            spotify.isRetrievingTokens = false
            
            if case .failure(let error) = completion {
                print("couldn't retrieve access and refresh tokens:\n\(error)")
                let alertTitle: String
                let alertMessage: String
                if let authError = error as? SpotifyAuthorizationError,
                   authError.accessWasDenied {
                    alertTitle = "You Denied The Authorization Request :("
                    alertMessage = ""
                }
                else {
                    alertTitle =
                    "Couldn't Authorization With Your Account"
                    alertMessage = error.localizedDescription
                }
                alert = AlertItem(
                    title: alertTitle, message: alertMessage
                )
            }
        })
        .store(in: &cancellables)
        
        /// IMPORTANT: generate a new value for the state parameter after
        /// each authorization request. This ensures an incoming redirect
        /// from Spotify was the result of a request made by this app, and
        /// and not an attacker.
        spotify.authorizationState = String.randomURLSafe(length: 128)
        
    }
}
