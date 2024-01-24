import Foundation
import GRDB

struct DBSongMetadata: Codable, FetchableRecord, MutablePersistableRecord {
    
    enum Columns: String, ColumnExpression {
        case id, title, artist, album, artworkURL, releaseDate, genreNames, isExplicit, appleMusicID, previewURL, playlistID, duration
    }
    
    static var databaseTableName = "songs"
    
    var id: String
    var title: String
    var artist: String
    var album: String
    var artworkURL: URL?
    var releaseDate: Date?
    var genreNames: [String]
    var isExplicit: Bool
    var appleMusicID: String
    var previewURL: URL?
    var playlistID: String?
    var duration: TimeInterval?
}

// MARK: Mock

extension DBSongMetadata {
    
    /// One mocked song.
    static var mockSong: DBSongMetadata {
        DBSongMetadata(id: "1", title: "Song 1", artist: "Artist 1", album: "Album 1", artworkURL: Bundle.main.url(forResource: "song-artwork-url", withExtension: "jpg"), releaseDate: nil, genreNames: ["Genre 1"], isExplicit: false, appleMusicID: "1", previewURL: nil, playlistID: nil, duration: nil)
    }
    
    /// Unique mocked songs with their own identifying metadata.
    static var mockSongs: [DBSongMetadata] {
        let songs = [
            DBSongMetadata(id: "1", title: "Song 1", artist: "Artist 1", album: "Album 1", artworkURL: Bundle.main.url(forResource: "song-artwork-url", withExtension: "jpg"), releaseDate: nil, genreNames: ["Genre 1"], isExplicit: false, appleMusicID: "1", previewURL: nil, playlistID: nil, duration: nil),
            DBSongMetadata(id: "2", title: "Song 2", artist: "Artist 2", album: "Album 2", artworkURL: Bundle.main.url(forResource: "song-artwork-url", withExtension: "jpg"), releaseDate: nil, genreNames: ["Genre 2"], isExplicit: false, appleMusicID: "2", previewURL: nil, playlistID: nil, duration: nil),
            DBSongMetadata(id: "3", title: "Song 3", artist: "Artist 3", album: "Album 3", artworkURL: Bundle.main.url(forResource: "song-artwork-url", withExtension: "jpg"), releaseDate: nil, genreNames: ["Genre 3"], isExplicit: false, appleMusicID: "3", previewURL: nil, playlistID: nil, duration: nil),
            DBSongMetadata(id: "4", title: "Song 4", artist: "Artist 4", album: "Album 4", artworkURL: Bundle.main.url(forResource: "song-artwork-url", withExtension: "jpg"), releaseDate: nil, genreNames: ["Genre 4"], isExplicit: false, appleMusicID: "4", previewURL: nil, playlistID: nil, duration: nil),
            DBSongMetadata(id: "5", title: "Song 5", artist: "Artist 5", album: "Album 5", artworkURL: Bundle.main.url(forResource: "song-artwork-url", withExtension: "jpg"), releaseDate: nil, genreNames: ["Genre 5"], isExplicit: false, appleMusicID: "5", previewURL: nil, playlistID: nil, duration: nil),
            DBSongMetadata(id: "6", title: "Song 6", artist: "Artist 6", album: "Album 6", artworkURL: Bundle.main.url(forResource: "song-artwork-url", withExtension: "jpg"), releaseDate: nil, genreNames: ["Genre 6"], isExplicit: false, appleMusicID: "6", previewURL: nil, playlistID: nil, duration: nil),
            DBSongMetadata(id: "7", title: "Song 7", artist: "Artist 7", album: "Album 7", artworkURL: Bundle.main.url(forResource: "song-artwork-url", withExtension: "jpg"), releaseDate: nil, genreNames: ["Genre 7"], isExplicit: false, appleMusicID: "7", previewURL: nil, playlistID: nil, duration: nil),
        ]
        
        return songs
    }
}
