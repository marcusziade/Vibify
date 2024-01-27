import SwiftUI

@main
struct VibifyApp: App {
    
    @State private var spotifyService = SpotifyService()
    
    var body: some Scene {
        WindowGroup {
            SpotifyAuthView()
                .environment(spotifyService)
                .onOpenURL { url in
                    if url.scheme == "com.marcusz.vibify" && url.host == "spotify-login-callback" {
                        if let code = url.queryItemValue(forKey: "code") {
                            Task {
                                try await spotifyService.exchangeCodeForToken(code: code)
                            }
                        } else if let error = url.queryItemValue(forKey: "error") {
                            print("Error during authentication: \(error)")
                        }
                    }
                }
            //            PlaylistGeneratorView(viewModel: initialize())
        }
    }
    
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
}
