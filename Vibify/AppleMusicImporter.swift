import Foundation
import StoreKit
import MediaPlayer
import MusicKit
import os.log

final class AppleMusicImporter {
    private let logger = Logger(subsystem: "com.marcusziade.Vibify.app", category: "MusicImport")
    
    func requestAppleMusicAccess() async -> Bool {
        logger.info("Requesting Apple Music access")
        let status = await SKCloudServiceController.requestAuthorization()
        logger.info("Apple Music access authorization status: \(String(describing: status))")
        let authorized = status == .authorized
        logger.info("Apple Music access \(authorized ? "granted" : "denied")")
        return authorized
    }
    
    func createPlaylist(named name: String) async throws -> MPMediaPlaylist {
        logger.info("Creating playlist with name: \(name)")
        let musicLibrary = MPMediaLibrary.default()
        let creationMetadata = MPMediaPlaylistCreationMetadata(name: name)
        
        do {
            let playlist = try await musicLibrary.getPlaylist(with: UUID(), creationMetadata: creationMetadata)
            logger.info("Playlist created successfully with name: \(name), id: \(playlist.persistentID)")
            return playlist
        } catch {
            logger.error("Failed to create playlist named: \(name), Error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func addSongsToPlaylist(
        playlist: MPMediaPlaylist,
        songs: [SongMetadata]
    ) async -> Result<Void, Error> {
        logger.info("Starting to add songs to the playlist, Playlist ID: \(playlist.persistentID)")
        do {
            for song in songs {
                let normalizedSearchTerm = song.title.normalizedForSearch()
                let normalizedArtist = song.artist.normalizedForSearch()
                
                logger.debug("Searching for song: \(song.title), Artist: \(song.artist)")
                let request = MusicCatalogSearchRequest(term: normalizedSearchTerm, types: [Song.self])
                let response = try await request.response()
                
                // Convert MusicItemCollection<Song> to [Song]
                let songsArray = response.songs.compactMap { $0 }
                
                // Now pass the array to your methods
                // First, try to find an exact match.
                if let foundSong = findMatchingSong(from: songsArray, title: song.title, artist: song.artist) {
                    try await add(foundSong, to: playlist)
                } else {
                    // If not found, attempt to search without the featured artists.
                    logger.debug("Exact match not found. Attempting search without featured artists.")
                    if let foundSong = findMatchingSongIgnoringFeatures(from: songsArray, title: song.title, artist: song.artist) {
                        try await add(foundSong, to: playlist)
                    } else {
                        // As a last resort, try searching by title only.
                        logger.debug("No match found when ignoring features. Attempting search by title only.")
                        if let foundSong = findSongByTitleOnly(from: songsArray, title: song.title) {
                            try await add(foundSong, to: playlist)
                        } else {
                            logger.warning("Song not found: \(song.title) by \(song.artist)")
                        }
                    }
                }
            }
            logger.info("All songs processed for playlist, Playlist ID: \(playlist.persistentID)")
            return .success(())
        } catch {
            logger.error("Error adding songs to playlist: \(error.localizedDescription)")
            return .failure(error)
        }
    }
    
    private func findMatchingSong(from songs: [Song], title: String, artist: String) -> Song? {
        let normalizedTitle = title.normalizedForSearch()
        let normalizedArtist = artist.normalizedForSearch()
        return songs.first {
            $0.title.normalizedForSearch() == normalizedTitle && $0.artistName.normalizedForSearch() == normalizedArtist
        }
    }
    
    private func findMatchingSongIgnoringFeatures(from songs: [Song], title: String, artist: String) -> Song? {
        let normalizedTitle = title.normalizedForSearch()
        let mainArtist = artist.components(separatedBy: " ft.")[0].normalizedForSearch()
        return songs.first {
            $0.title.normalizedForSearch() == normalizedTitle && $0.artistName.normalizedForSearch().contains(mainArtist)
        }
    }
    
    private func findSongByTitleOnly(from songs: [Song], title: String) -> Song? {
        let normalizedTitle = title.normalizedForSearch()
        return songs.first { $0.title.normalizedForSearch() == normalizedTitle }
    }
    
    private func add(_ song: Song, to playlist: MPMediaPlaylist) async throws {
        logger.debug("Adding song to playlist: \(song.title) by \(song.artistName), Product ID: \(song.id.rawValue)")
        try await playlist.addItem(withProductID: song.id.rawValue)
    }
}
