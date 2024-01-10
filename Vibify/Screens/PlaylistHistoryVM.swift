import Foundation
import Observation
import os.log

@Observable
final class PlaylistHistoryViewModel {
    
    var playlistHistory: [DBPlaylist] = []
    
    init(dbManager: DatabaseManager) {
        self.databaseManager = dbManager
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
    
    private let databaseManager: DatabaseManager
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "PlaylistHistoryViewModel")
}
