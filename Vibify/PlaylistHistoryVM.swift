import Foundation
import Observation

@Observable
final class PlaylistHistoryViewModel {
    
    var playlistHistory: [DBPlaylist] = []
    
    init(dbManager: DatabaseManager = DatabaseManager()) {
        self.databaseManager = dbManager
        fetchPlaylistHistory()
    }
    
    func fetchPlaylistHistory() {
        do {
            playlistHistory = try databaseManager.fetchPlaylistHistory()
        } catch {
            print("Error fetching playlist history: \(error)")
        }
    }
    
    private let databaseManager: DatabaseManager
}
