import Foundation
import GRDB

struct DBSongMetadata: Codable, FetchableRecord, MutablePersistableRecord {
    
    enum Columns: String, ColumnExpression {
        case id, title, artist, album, artworkURL, releaseDate, genreNames, isExplicit, appleMusicID, previewURL, playlistID
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
}
