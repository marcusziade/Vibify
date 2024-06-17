import Foundation
import SwiftData

@Model final class DBPlaylist: Identifiable {
    var title: String = ""
    var playlistID: String = ""
    var createdAt: Date = Date.now
    @Relationship(deleteRule: .cascade, inverse: \DBTrack.playlist)
    var tracks: [DBTrack]? = []
    var artworkFileName: String? = nil
    
    var trackCount: Int {
        tracks?.count ?? 0
    }
    
    var trackTitles: [String] {
        tracks?.compactMap(\.title) ?? []
    }
    
    var songArtworks: [URL] {
        tracks?.compactMap { $0.artworkName } ?? []
    }
    
    var duration: TimeInterval {
        tracks?.reduce(.zero) { $0 + ($1.duration ?? .zero) } ?? .zero
    }
    
    var topTwoGenres: [String] {
        let genreCounts = tracks?
            .flatMap { $0.genreNames }
            .filter { $0 != "Music" }
            .reduce(into: [:]) { counts, genre in
                counts[genre, default: 0] += 1
            } ?? [:]
        
        return Array(genreCounts.sorted { $0.value > $1.value }.prefix(2).map { $0.key })
    }

    init(
        title: String,
        playlistID: String = UUID().uuidString,
        createdAt: Date = Date.now,
        tracks: [DBTrack]? = nil,
        artworkName: String? = nil
    ) {
        self.title = title
        self.playlistID = playlistID
        self.createdAt = createdAt
        self.tracks = tracks
        self.artworkFileName = artworkName
    }
}

extension DBPlaylist {
    
    func artworkImageURL() throws -> URL? {
        guard let filename = artworkFileName else { return nil }
        let dir = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        let url = dir.appending(path: filename)
        if FileManager.default.fileExists(atPath: url.path) {
            return url
        }
        
        return nil
    }
}

// MARK: Mock

extension DBPlaylist {
    
    static var mock: DBPlaylist {
        let filename = UUID().uuidString + ".png"
        saveDataToDocumentsDirectory(filename: filename)
        let id = UUID().uuidString
        return DBPlaylist(
            title: "My Playlist",
            playlistID: UUID().uuidString,
            createdAt: Date(),
            tracks: DBTrack.mockSongs,
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
                playlistID: UUID().uuidString,
                createdAt: Date(),
                tracks: [],
                artworkName: filename
            ),
            DBPlaylist(
                title: "Playlist 2",
                playlistID: UUID().uuidString,
                createdAt: Date(),
                tracks: [],
                artworkName: filename
            ),
            DBPlaylist(
                title: "Playlist 3",
                playlistID: UUID().uuidString,
                createdAt: Date(),
                tracks: [],
                artworkName: filename
            ),
            DBPlaylist(
                title: "Playlist 4",
                playlistID: UUID().uuidString,
                createdAt: Date(),
                tracks: [],
                artworkName: filename
            ),
            DBPlaylist(
                title: "Playlist 5",
                playlistID: UUID().uuidString,
                createdAt: Date(),
                tracks: [],
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
