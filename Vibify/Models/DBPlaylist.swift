import Foundation
import GRDB

struct DBPlaylist: FetchableRecord, MutablePersistableRecord, Identifiable {
    static var databaseTableName = "playlists"

    var title: String
    var playlistID: String
    var createdAt: Date
    var songs: [DBSongMetadata]?
    var artworkName: String?

    var songsCount: Int {
        songs?.count ?? 0
    }

    var songTitles: [String] {
        songs?.compactMap { $0.title } ?? []
    }

    var songArtworkNames: [URL] {
        songs?.compactMap(\.artworkName) ?? []
    }

    var duration: TimeInterval {
        songs?.reduce(0) { $0 + ($1.duration ?? .zero) } ?? 0
    }

    var topTwoGenres: [String] {
        let genreCounts =
            songs?.flatMap { $0.genreNames }
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
        case artworkName
    }

    init(
        title: String,
        playlistID: String,
        createdAt: Date,
        songs: [DBSongMetadata]?,
        artworkName: String? = nil
    ) {
        self.title = title
        self.playlistID = playlistID
        self.createdAt = createdAt
        self.songs = songs
        self.artworkName = artworkName
    }

    init(row: Row) {
        title = row[Columns.title]
        playlistID = row[Columns.playlistID]
        createdAt = row[Columns.createdAt]
        artworkName = row[Columns.artworkName]
        songs = nil
    }

    func encode(to container: inout PersistenceContainer) {
        container[Columns.title] = title
        container[Columns.playlistID] = playlistID
        container[Columns.createdAt] = createdAt
        container[Columns.artworkName] = artworkName
        // Do not encode 'songs' as it's not part of the database schema
    }

    var id: String { playlistID }
}

extension DBPlaylist {

    func artworkImageURL() throws -> URL? {
        guard let artworkFilename = artworkName else { return nil }

        let documentsDirectory = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        let fileURL = documentsDirectory.appendingPathComponent(artworkFilename)

        if FileManager.default.fileExists(atPath: fileURL.path) {
            return fileURL
        }

        return nil
    }
}

// MARK: Mock

extension DBPlaylist {

    static var mock: DBPlaylist {
        let filename = UUID().uuidString + ".png"
        saveDataToDocumentsDirectory(filename: filename)

        return DBPlaylist(
            title: "My Playlist",
            playlistID: UUID().uuidString,
            createdAt: Date(),
            songs: DBSongMetadata.mockSongs,
            artworkName: filename
        )
    }

    /// Five unique mocked playlists with their own identifying metadata.
    static var mockPlaylists: [DBPlaylist] {
        let filename = UUID().uuidString + ".png"
        saveDataToDocumentsDirectory(filename: filename)
        let playlists = [
            DBPlaylist(
                title: "Playlist 1",
                playlistID: "1",
                createdAt: Date(),
                songs: DBSongMetadata.mockSongs,
                artworkName: filename
            ),
            DBPlaylist(
                title: "Playlist 2",
                playlistID: "2",
                createdAt: Date(),
                songs: DBSongMetadata.mockSongs,
                artworkName: filename
            ),
            DBPlaylist(
                title: "Playlist 3",
                playlistID: "3",
                createdAt: Date(),
                songs: DBSongMetadata.mockSongs,
                artworkName: filename
            ),
            DBPlaylist(
                title: "Playlist 4",
                playlistID: "4",
                createdAt: Date(),
                songs: DBSongMetadata.mockSongs,
                artworkName: filename
            ),
            DBPlaylist(
                title: "Playlist 5",
                playlistID: "5",
                createdAt: Date(),
                songs: DBSongMetadata.mockSongs,
                artworkName: filename
            ),
        ]

        return playlists
    }

    /// Saves data to the specified filename within the documents directory.
    private static func saveDataToDocumentsDirectory(filename: String) {
        let url = Bundle.main.url(forResource: "dalle-sample", withExtension: "png")!
        let data = try! Data(contentsOf: url)
        guard
            let documentsDirectory = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first
        else {
            print("Failed to locate documents directory")
            return
        }

        let fileURL = documentsDirectory.appendingPathComponent(filename)

        do {
            try data.write(to: fileURL)
            print("File saved: \(fileURL.absoluteString)")
        } catch {
            print("Error saving file: \(error)")
        }
    }
}
