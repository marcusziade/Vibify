import Foundation
import SwiftData

@Model final class DBTrack {
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
    var playlist: DBPlaylist?

    init(
        id: String,
        title: String,
        artist: String,
        album: String,
        artworkName: URL? = nil,
        releaseDate: Date? = nil,
        genreNames: [String],
        isExplicit: Bool,
        appleMusicID: String,
        previewURL: URL? = nil,
        playlistID: String? = nil,
        duration: TimeInterval? = nil
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.artworkName = artworkName
        self.releaseDate = releaseDate
        self.genreNames = genreNames
        self.isExplicit = isExplicit
        self.appleMusicID = appleMusicID
        self.previewURL = previewURL
        self.playlistID = playlistID
        self.duration = duration
    }
}

// MARK: Mock

extension DBTrack {
    
    /// One mocked song.
    static var mockSong: DBTrack {
        let image = Bundle.main.url(forResource: "song-artwork-url", withExtension: "jpeg")!
        return .init(
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
    static var mockSongs: [DBTrack] {
        let image = Bundle.main.url(forResource: "song-artwork-url", withExtension: "jpeg")!
        let songs = (1...15).map { index in
            DBTrack(
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
