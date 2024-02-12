import Foundation

/// A protocol for managing database interactions related to playlists.
///
/// This protocol abstracts the database layer, allowing for operations such as
/// inserting new playlists, fetching playlist history, and updating playlist details.
/// Conforming to this protocol enables easier testing and more modular architecture.
protocol DatabaseManaging {
    
    /// Inserts a new playlist into the database.
    ///
    /// This method allows the addition of a new playlist to the database. It throws an error
    /// if the insertion operation fails. Implementations of this method should handle all aspects
    /// of database interaction necessary to persist the playlist data.
    ///
    /// - Parameters:
    ///   - playlist: The `DBPlaylist` object to insert into the database.
    /// - Throws: An error if the playlist cannot be inserted.
    func insert(playlist: DBPlaylist) throws
    
    /// Fetches and returns the history of playlists stored in the database.
    ///
    /// This method retrieves all playlists previously stored in the database.
    /// It returns an array of `DBPlaylist` objects, each representing a playlist.
    /// The method throws an error if it fails to fetch the playlist history.
    ///
    /// - Returns: An array of `DBPlaylist` objects representing the playlist history.
    /// - Throws: An error if the playlist history cannot be fetched.
    func fetchPlaylistHistory() throws -> [DBPlaylist]
    
    /// Updates the artwork URL of a specific playlist identified by its ID.
    ///
    /// This method updates the artwork URL of an existing playlist in the database.
    /// It throws an error if the update operation fails.
    ///
    /// - Parameters:
    ///   - playlistID: A `String` representing the unique identifier of the playlist.
    ///   - artworkName: A `String` representing the new artwork URL to be associated with the playlist.
    /// - Throws: An error if the artwork URL cannot be updated for the specified playlist.
    func updatePlaylistArtworkName(playlistID: String, artworkName: String) throws
}
