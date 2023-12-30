import Foundation
import StoreKit
import MediaPlayer
import MusicKit

final class AppleMusicImporter {
    
    func requestAppleMusicAccess() async -> Bool {
        let status = await SKCloudServiceController.requestAuthorization()
        return status == .authorized
    }
    
    func createPlaylist(named name: String) async throws -> MPMediaPlaylist {
        let musicLibrary = MPMediaLibrary.default()
        let creationMetadata = MPMediaPlaylistCreationMetadata(name: name)
        
        let playlist = try await musicLibrary.getPlaylist(with: UUID(), creationMetadata: creationMetadata)
        return playlist
    }
    
    func addSongsToPlaylist(
        playlist: MPMediaPlaylist,
        songs: [SongMetadata]
    ) async -> Result<Void, Error> {
        do {
            for song in songs {
                let request = MusicCatalogSearchRequest(term: song.title, types: [Song.self])
                let response = try await request.response()
                
                guard let foundSong = response.songs.first(where: { $0.title == song.title && $0.artistName == song.artist }) else {
                    print("Song not found: \(song.title)")
                    continue
                }
                
                try await playlist.addItem(withProductID: foundSong.id.rawValue)
            }
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
