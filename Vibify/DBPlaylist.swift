import Foundation
import GRDB

struct DBPlaylist: FetchableRecord, MutablePersistableRecord, Identifiable {
    static var databaseTableName = "playlists"
    
    var title: String
    var playlistID: String
    var createdAt: Date
    var songs: [DBSongMetadata]?
    
    var songsCount: Int {
        songs?.count ?? 0
    }
    
    var songTitles: [String] {
        songs?.compactMap { $0.title } ?? []
    }
    
    var songArtworkURLs: [URL] {
        songs?.compactMap(\.artworkURL) ?? []
    }
    
    var duration: TimeInterval {
        songs?.reduce(0) { $0 + ($1.duration ?? .zero) } ?? 0
    }
    
    var topTwoGenres: [String] {
        let genreCounts = songs?.flatMap { $0.genreNames }
            .filter { $0 != "Music" }
            .reduce(into: [:]) { counts, genre in
                counts[genre, default: 0] += 1
            } ?? [:]
        
        return Array(genreCounts.sorted { $0.value > $1.value }.prefix(2).map { $0.key })
    }

    enum Columns: String, ColumnExpression {
        case title
        case playlistID = "id"
        case createdAt
    }
    
    init(title: String, playlistID: String, createdAt: Date, songs: [DBSongMetadata]?) {
        self.title = title
        self.playlistID = playlistID
        self.createdAt = createdAt
        self.songs = songs
    }
    
    init(row: Row) {
        title = row[Columns.title]
        playlistID = row[Columns.playlistID]
        createdAt = row[Columns.createdAt]
        songs = nil
    }
    
    func encode(to container: inout PersistenceContainer) {
        container[Columns.title] = title
        container[Columns.playlistID] = playlistID
        container[Columns.createdAt] = createdAt
        // Do not encode 'songs' as it's not part of the database schema
    }
    
    var id: String { playlistID }
}
