import Foundation
import GRDB
import os.log

class DatabaseManager {
    private let dbQueue: DatabaseQueue
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "DatabaseManager")
    
    init() {
        do {
            let databaseURL = try FileManager.default
                .url(
                    for: .applicationSupportDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: true
                )
                .appendingPathComponent("playlistDatabase.sqlite")
            dbQueue = try DatabaseQueue(path: databaseURL.path)
            
            try dbQueue.write { db in
                try db.create(table: "songs", ifNotExists: true) { t in
                    t.column("id", .text).primaryKey()
                    t.column("title", .text)
                    t.column("artist", .text)
                    t.column("album", .text)
                    t.column("artworkURL", .text)
                    t.column("releaseDate", .date)
                    t.column("genreNames", .text)
                    t.column("isExplicit", .boolean)
                    t.column("appleMusicID", .text)
                    t.column("previewURL", .text)
                    t.column("playlistID", .text)
                }
                
                try db.create(table: "playlists", ifNotExists: true) { t in
                    t.column("id", .text).primaryKey()
                    t.column("createdAt", .date)
                }
            }
        } catch {
            logger.error("Database initialization failed: \(error.localizedDescription)")
            fatalError("Database initialization failed: \(error.localizedDescription)")
        }
    }
    
    func insert(playlist: DBPlaylist) throws {
        do {
            var mutatingPlaylist = playlist
            try dbQueue.write { db in
                try mutatingPlaylist.insert(db)
                logger.info("Inserted playlist with id: \(mutatingPlaylist.id)")
            }
        } catch {
            logger.error("Failed to insert playlist: \(error.localizedDescription)")
            throw error
        }
    }
    
    // Add more functions as needed for fetching, updating, and deleting songs
}

extension DatabaseManager {
    
    func fetchPlaylistHistory() throws -> [DBPlaylist] {
        var history: [DBPlaylist] = []
        try dbQueue.read { db in
            let playlists = try DBPlaylist.fetchAll(db)
            
            for var playlist in playlists {
                let songs = try DBSongMetadata
                    .filter(Column("playlistID") == playlist.playlistID)
                    .fetchAll(db)
                playlist.songs = songs
                history.append(playlist)
            }
        }
        return history
    }
}
