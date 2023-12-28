import Foundation
import StoreKit
import MediaPlayer

final class AppleMusicImporter {
    
    // Request authorization for Apple Music access
    func requestAppleMusicAccess(completion: @escaping (Bool) -> Void) {
        SKCloudServiceController.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(status == .authorized)
            }
        }
    }
    
    // Create a new playlist in the user's Apple Music account
    func createPlaylist(named name: String, completion: @escaping (MPMediaPlaylist?, Error?) -> Void) {
        let musicLibrary = MPMediaLibrary.default()
        let creationMetadata = MPMediaPlaylistCreationMetadata(name: name)
        
        musicLibrary.getPlaylist(with: UUID(), creationMetadata: creationMetadata) { playlist, error in
            DispatchQueue.main.async {
                completion(playlist, error)
            }
        }
    }
    
    // Method to add songs to a playlist
    func addSongsToPlaylist(
        playlist: MPMediaPlaylist,
        songTitles: [String],
        completion: @escaping (Bool, Error?) -> Void
    ) {
        let musicLibrary = MPMediaLibrary.default()
        
        // Fetch all songs that match the titles
        let songsToAdd = songTitles.compactMap { title -> MPMediaItem? in
            let query = MPMediaQuery.songs()
            query.addFilterPredicate(
                MPMediaPropertyPredicate(
                    value: title,
                    forProperty: MPMediaItemPropertyTitle,
                    comparisonType: .equalTo
                )
            )
            return query.items?.first
        }
        
        // Add songs to the playlist
        var errorsOccurred: Bool = false
        let group = DispatchGroup()
        
        for song in songsToAdd {
            group.enter()
            musicLibrary.addItem(withProductID: song.playbackStoreID) { entity, error in
                DispatchQueue.main.async {
                    if error != nil {
                        errorsOccurred = true
                    }
                    group.leave()
                }
            }
        }
        
        // Completion handling
        group.notify(queue: DispatchQueue.main) {
            completion(
                !errorsOccurred,
                errorsOccurred ? NSError(
                    domain: "AppleMusicImporter",
                    code: -2,
                    userInfo: [NSLocalizedDescriptionKey: "Error occurred while adding songs"]
                ) : nil
            )
        }
    }
}
