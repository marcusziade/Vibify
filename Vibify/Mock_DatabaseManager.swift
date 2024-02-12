import Foundation

final class Mock_DatabaseManager: DatabaseManaging {
    
    var didCallInsert = false
    var didCallFetchPlaylistHistory = false
    var didCallUpdatePlaylistArtworkName = false
    
    func insert(playlist: DBPlaylist) throws {
        didCallInsert = true
        // Mock behavior
    }
    
    func fetchPlaylistHistory() throws -> [DBPlaylist] {
        didCallFetchPlaylistHistory = true
        return DBPlaylist.mockPlaylists
    }
    
    func updatePlaylistArtworkName(playlistID: String, artworkName: String) throws {
        didCallUpdatePlaylistArtworkName = true
        // Mock behavior
    }
}
