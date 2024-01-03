import Foundation
import StoreKit
import MediaPlayer
import MusicKit
import os.log

/// A class responsible for importing songs into Apple Music.
final class AppleMusicImporter {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "MusicImport")
    
    /// Requests authorization for accessing Apple Music.
    func requestAppleMusicAccess() async -> Bool {
        logger.info("Requesting Apple Music access")
        let status = await SKCloudServiceController.requestAuthorization()
        let status2 = await MPMediaLibrary.requestAuthorization()
        logger.info("Apple Music access authorization status: \(String(describing: status))")
        return status == .authorized && status2 == .authorized
    }
    
    /// Creates a new playlist in Apple Music with a given name.
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
    
    /// Adds songs to a given Apple Music playlist and updates progress.
    func addSongsToPlaylist(
        playlist: MPMediaPlaylist,
        songs: [DBSongMetadata],
        progressHandler: @escaping (Double) -> Void
    ) async -> Result<Void, Error> {
        logger.info("Starting to add songs to the playlist, Playlist ID: \(playlist.persistentID)")
        do {
            let totalSongs = Double(songs.count)
            var processedSongs = 0.0
            
            for song in songs {
                logger.debug("Searching for song: \(song.title), Artist: \(song.artist)")
                let request = MusicCatalogSearchRequest(term: "\(song.title) \(song.artist)", types: [Song.self])
                let response = try await request.response()
                
                if let foundSong = response.songs.first(where: { $0.matchesMetadata(song) }) {
                    try await add(foundSong, to: playlist)
                } else {
                    logger.warning("Song not found: \(song.title) by \(song.artist)")
                }
                
                processedSongs += 1
                let progress = processedSongs / totalSongs
                progressHandler(progress)
            }
            logger.info("All songs processed for playlist, Playlist ID: \(playlist.persistentID)")
            return .success(())
        } catch {
            logger.error("Error adding songs to playlist: \(error.localizedDescription)")
            return .failure(error)
        }
    }
    
    /// Adds a single song to a given Apple Music playlist.
    private func add(_ song: Song, to playlist: MPMediaPlaylist) async throws {
        logger.debug("Adding song to playlist: \(song.title) by \(song.artistName), Product ID: \(song.id.rawValue)")
        try await playlist.addItem(withProductID: song.id.rawValue)
    }
}

/// Extension to provide a utility method for matching `Song` with `DBSongMetadata`.
extension Song {
    /// Determines if a `Song` instance matches a given `DBSongMetadata`.
    func matchesMetadata(_ metadata: DBSongMetadata) -> Bool {
        let normalizedTitle = self.title.normalizedForSearch()
        let normalizedArtist = self.artistName.normalizedForSearch()
        let normalizedAlbum = self.albumTitle?.normalizedForSearch() ?? ""
        
        return normalizedTitle == metadata.title.normalizedForSearch() &&
        normalizedArtist == metadata.artist.normalizedForSearch() &&
        (metadata.album.isEmpty || normalizedAlbum == metadata.album.normalizedForSearch())
    }
}
