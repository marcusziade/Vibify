import Foundation
import Observation
import os.log

@Observable
final class PlaylistHistoryViewModel {
    
    var playlistHistory: [DBPlaylist] = []
    var importProgress: Double = 0.0
    var importingState: [String: Bool] = [:]
    private let appleMusicImporter: AppleMusicImporter
    private let databaseManager: DatabaseManaging
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "PlaylistHistoryViewModel")
    
    init(dbManager: DatabaseManaging, appleMusicImporter: AppleMusicImporter) {
        self.databaseManager = dbManager
        self.appleMusicImporter = appleMusicImporter
        fetchPlaylistHistory()
    }
    
    func fetchPlaylistHistory() {
        do {
            playlistHistory = try databaseManager.fetchPlaylistHistory()
            logger.info("Fetched playlist history: \(self.playlistHistory.map(\.songs))")
        } catch {
            print("Error fetching playlist history: \(error)")
        }
    }
    
    func importPlaylistToAppleMusic(playlist: DBPlaylist) async {
        logger.info("Starting to import playlist to Apple Music: \(playlist.title)")
        importingState[playlist.id] = true
        importProgress = 0.0
        
        guard await appleMusicImporter.requestAppleMusicAccess() else {
            logger.error("User not authorized for Apple Music")
            return
        }
        
        guard let songs = playlist.songs else {
            logger.error("No songs in playlist")
            return
        }
        
        do {
            let createdPlaylist = try await appleMusicImporter.createPlaylist(named: playlist.title)
            let result = await appleMusicImporter.addSongsToPlaylist(
                playlist: createdPlaylist,
                songs: songs,
                progressHandler: { [unowned self] newProgress in
                    importProgress = newProgress
                }
            )
            switch result {
            case .success():
                logger.info("Playlist \(playlist.title) imported to Apple Music successfully.")
            case .failure(let error):
                logger.error("Failed to import playlist to Apple Music: \(error.localizedDescription)")
            }
        } catch {
            logger.error("Failed to import playlist: \(error.localizedDescription)")
        }
        
        importingState[playlist.id] = false
        importProgress = 0.0
    }
}
