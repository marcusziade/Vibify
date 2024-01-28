import SpotifyWebAPI
import SwiftUI

@main
struct VibifyApp: App {
    
    @State private var spotify = SpotifyService()
    
    init() {
        SpotifyAPILogHandler.bootstrap()
    }
    
    var body: some Scene {
        WindowGroup {
#warning("Replace this with a root view.")
            PlaylistGeneratorView(viewModel: initialize())
                .environment(spotify)
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
