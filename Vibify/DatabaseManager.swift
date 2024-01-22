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
                    t.column("duration", .double)
                }
                
                try db.create(table: "playlists", ifNotExists: true) { t in
                    t.column("id", .text).primaryKey()
                    t.column("createdAt", .date)
                    t.column("title", .text)
                    t.column("artworkURL", .text)
                }
            }
        } catch {
            logger.error("Database initialization failed: \(error.localizedDescription)")
            fatalError("Database initialization failed: \(error.localizedDescription)")
        }
    }
}

extension DatabaseManager {
    
    func insert(playlist: DBPlaylist) throws {
        var mutatingPlaylist = playlist
        do {
            try dbQueue.write { db in
                try mutatingPlaylist.insert(db)
                logger.info("Inserted playlist with id: \(mutatingPlaylist.id)")
                
                if let songs = mutatingPlaylist.songs {
                    for var song in songs {
                        song.playlistID = mutatingPlaylist.playlistID
                        try song.insert(db)
                        logger.info("Inserted song with id: \(song.id) into playlist with id: \(mutatingPlaylist.id)")
                    }
                }
            }
        } catch {
            logger.error("Failed to insert playlist or songs: \(error.localizedDescription)")
            throw error
        }
    }
}

extension DatabaseManager {
    
    func fetchPlaylistHistory() throws -> [DBPlaylist] {
        var history: [DBPlaylist] = []
        do {
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
        } catch {
            logger.error("Failed to fetch playlist history: \(error.localizedDescription)")
            throw error
        }
        return history
    }
}

extension DatabaseManager {
    
    func updatePlaylistArtworkURL(playlistID: String, artworkURL: String) throws {
        do {
            try dbQueue.write { db in
                let request = DBPlaylist.filter(DBPlaylist.Columns.playlistID == playlistID)
                try request.updateAll(db, [DBPlaylist.Columns.artworkURL.set(to: artworkURL)])
                logger.info("Updated artwork URL for playlist with id: \(playlistID)")
            }
        } catch {
            logger.error("Failed to update artwork URL for playlist: \(error.localizedDescription)")
            throw error
        }
    }
}
