import Foundation
import MusicKit

struct SongMetadata: Identifiable {
    let id: UUID = UUID()
    let title: String
    let artist: String
    let album: String
    let artworkURL: URL?
    let releaseDate: Date?
    let genreNames: [String]
    let isExplicit: Bool
    let appleMusicID: MusicItemID
}
