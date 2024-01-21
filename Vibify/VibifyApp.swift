import SwiftUI

@main
struct VibifyApp: App {
    
    var body: some Scene {
        WindowGroup {
            PlaylistGeneratorView(viewModel: initialize())
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
