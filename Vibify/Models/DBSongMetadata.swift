import Foundation
import GRDB

struct DBSongMetadata: Codable, FetchableRecord, MutablePersistableRecord {

    enum Columns: String, ColumnExpression {
        case id, title, artist, album, artworkName, releaseDate, genreNames, isExplicit,
            appleMusicID, previewURL, playlistID, duration
    }

    static var databaseTableName = "songs"

    var id: String
    var title: String
    var artist: String
    var album: String
    var artworkName: URL?
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
        let image = Bundle.main.url(forResource: "song-artwork-url", withExtension: "jpeg")!
        return DBSongMetadata(
            id: "1",
            title: "Song 1",
            artist: "Artist 1",
            album: "Album 1",
            artworkName: image,
            releaseDate: nil,
            genreNames: ["Genre 1"],
            isExplicit: false,
            appleMusicID: "1",
            previewURL: nil,
            playlistID: nil,
            duration: nil
        )
    }

    /// Unique mocked songs with their own identifying metadata.
    static var mockSongs: [DBSongMetadata] {
        let image = Bundle.main.url(forResource: "song-artwork-url", withExtension: "jpeg")!
        let songs = (1...15).map { index in
            DBSongMetadata(
                id: "\(index)",
                title: "Song \(index)",
                artist: "Artist \(index)",
                album: "Album \(index)",
                artworkName: image,
                releaseDate: nil,
                genreNames: ["Genre \(index)"],
                isExplicit: false,
                appleMusicID: "\(index)",
                previewURL: nil,
                playlistID: nil,
                duration: nil
            )
        }

        return songs
    }
}
