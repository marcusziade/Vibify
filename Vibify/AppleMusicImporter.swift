import Foundation
import StoreKit
import MediaPlayer
import MusicKit

final class AppleMusicImporter {
    
    // Request authorization for Apple Music access
    func requestAppleMusicAccess() async -> Bool {
        let status = await SKCloudServiceController.requestAuthorization()
        return status == .authorized
    }
    
    // Create a new playlist in the user's Apple Music account
    func createPlaylist(named name: String) async throws -> MPMediaPlaylist {
        let musicLibrary = MPMediaLibrary.default()
        let creationMetadata = MPMediaPlaylistCreationMetadata(name: name)
        
        let playlist = try await musicLibrary.getPlaylist(with: UUID(), creationMetadata: creationMetadata)
        return playlist
    }
    
    // Method to add songs to an Apple Music playlist
    func addSongsToPlaylist(
        playlist: MPMediaPlaylist,
        songTitles: [String]
    ) async -> Result<Void, Error> {
        do {
            for title in songTitles {
                let request = MusicCatalogSearchRequest(term: title, types: [Song.self])
                let response = try await request.response()
                
                guard let song = response.songs.first else {
                    print("Song not found: \(title)")
                    continue
                }
                
                try await playlist.addItem(withProductID: song.id.rawValue)
            }
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
