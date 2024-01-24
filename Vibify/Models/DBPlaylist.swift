import Foundation
import GRDB

struct DBPlaylist: FetchableRecord, MutablePersistableRecord, Identifiable {
    static var databaseTableName = "playlists"
    
    var title: String
    var playlistID: String
    var createdAt: Date
    var songs: [DBSongMetadata]?
    var artworkURL: String?
    
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
        case artworkURL
    }
    
    init(
        title: String,
        playlistID: String,
        createdAt: Date,
        songs: [DBSongMetadata]?,
        artworkURL: String? = nil
    ) {
        self.title = title
        self.playlistID = playlistID
        self.createdAt = createdAt
        self.songs = songs
        self.artworkURL = artworkURL
    }
    
    init(row: Row) {
        title = row[Columns.title]
        playlistID = row[Columns.playlistID]
        createdAt = row[Columns.createdAt]
        artworkURL = row[Columns.artworkURL]
        songs = nil
    }
    
    func encode(to container: inout PersistenceContainer) {
        container[Columns.title] = title
        container[Columns.playlistID] = playlistID
        container[Columns.createdAt] = createdAt
        container[Columns.artworkURL] = artworkURL
        // Do not encode 'songs' as it's not part of the database schema
    }
    
    var id: String { playlistID }
}

// MARK: Mock

extension DBPlaylist {
    
    static var mock: DBPlaylist {
        DBPlaylist(
            title: "My Playlist",
            playlistID: UUID().uuidString,
            createdAt: Date(),
            songs: DBSongMetadata.mockSongs,
            artworkURL: Bundle.main.url(forResource: "dalle-sample", withExtension: "png")!.absoluteString
        )
    }
    
    /// Five unique mocked playlists with their own identifying metadata.
    static var mockPlaylists: [DBPlaylist] {
        let playlists = [
            DBPlaylist(title: "Playlist 1", playlistID: "1", createdAt: Date(), songs: DBSongMetadata.mockSongs, artworkURL: Bundle.main.url(forResource: "dalle-sample", withExtension: "png")!.absoluteString),
            DBPlaylist(title: "Playlist 2", playlistID: "2", createdAt: Date(), songs: DBSongMetadata.mockSongs, artworkURL: Bundle.main.url(forResource: "dalle-sample", withExtension: "png")!.absoluteString),
            DBPlaylist(title: "Playlist 3", playlistID: "3", createdAt: Date(), songs: DBSongMetadata.mockSongs, artworkURL: Bundle.main.url(forResource: "dalle-sample", withExtension: "png")!.absoluteString),
            DBPlaylist(title: "Playlist 4", playlistID: "4", createdAt: Date(), songs: DBSongMetadata.mockSongs, artworkURL: Bundle.main.url(forResource: "dalle-sample", withExtension: "png")!.absoluteString),
            DBPlaylist(title: "Playlist 5", playlistID: "5", createdAt: Date(), songs: DBSongMetadata.mockSongs, artworkURL: Bundle.main.url(forResource: "dalle-sample", withExtension: "png")!.absoluteString),
        ]
        
        return playlists
    }
}
