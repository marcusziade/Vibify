import Foundation

final class Mock_DatabaseManager: DatabaseManaging {
    
    var didCallInsert = false
    var didCallFetchPlaylistHistory = false
    var didCallUpdatePlaylistArtworkURL = false
    
    func insert(playlist: DBPlaylist) throws {
        didCallInsert = true
        // Mock behavior
    }
    
    func fetchPlaylistHistory() throws -> [DBPlaylist] {
        didCallFetchPlaylistHistory = true
        return DBPlaylist.mockPlaylists
    }
    
    func updatePlaylistArtworkURL(playlistID: String, artworkURL: String) throws {
        didCallUpdatePlaylistArtworkURL = true
        // Mock behavior
    }
}
