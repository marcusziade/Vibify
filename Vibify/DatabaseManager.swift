import Foundation
import GRDB
import os.log

final class DatabaseManager: DatabaseManaging {
    private let dbQueue: DatabaseQueue
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "DatabaseManager")
    
    init(databaseURL: URL? = nil) {
        do {
            let dbURL = databaseURL ?? DatabaseManager.defaultDatabaseURL()
            dbQueue = try DatabaseQueue(path: dbURL.path)
            try setupDatabase()
        } catch {
            logger.error("Database initialization failed: \(error.localizedDescription)")
            fatalError("Database initialization failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Methods
    
    private func setupDatabase() throws {
        try dbQueue.write { db in
            try createTables(in: db)
        }
    }
    
    private func createTables(in db: Database) throws {
        try db.create(table: "songs", ifNotExists: true) { t in
            t.column(Columns.id, .text).primaryKey()
            t.column(Columns.title, .text)
            t.column(Columns.artist, .text)
            t.column(Columns.album, .text)
            t.column(Columns.artworkName, .text)
            t.column(Columns.releaseDate, .date)
            t.column(Columns.genreNames, .text)
            t.column(Columns.isExplicit, .boolean)
            t.column(Columns.appleMusicID, .text)
            t.column(Columns.previewURL, .text)
            t.column(Columns.playlistID, .text)
            t.column(Columns.duration, .double)
        }
        
        try db.create(table: "playlists", ifNotExists: true) { t in
            t.column(Columns.id, .text).primaryKey()
            t.column(Columns.createdAt, .date)
            t.column(Columns.title, .text)
            t.column(Columns.artworkName, .text)
        }
    }
    
    private static func defaultDatabaseURL() -> URL {
        do {
            let url = try FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            ).appendingPathComponent("playlistDatabase.sqlite")
            return url
        } catch {
            fatalError("Failed to create database URL: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Columns
    
    private struct Columns {
        static let id = "id"
        static let title = "title"
        static let artist = "artist"
        static let album = "album"
        static let artworkName = "artworkName"
        static let releaseDate = "releaseDate"
        static let genreNames = "genreNames"
        static let isExplicit = "isExplicit"
        static let appleMusicID = "appleMusicID"
        static let previewURL = "previewURL"
        static let playlistID = "playlistID"
        static let duration = "duration"
        static let createdAt = "createdAt"
    }
}

// MARK: - Database Operations

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
    
    func updatePlaylistArtworkName(playlistID: String, artworkName: String) throws {
        do {
            try dbQueue.write { db in
                let request = DBPlaylist.filter(DBPlaylist.Columns.playlistID == playlistID)
                try request.updateAll(db, [DBPlaylist.Columns.artworkName.set(to: artworkName)])
                logger.info("Updated artwork URL for playlist with id: \(playlistID)")
            }
        } catch {
            logger.error("Failed to update artwork URL for playlist: \(error.localizedDescription)")
            throw error
        }
    }
}
