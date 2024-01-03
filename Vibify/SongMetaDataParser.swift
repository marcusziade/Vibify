import Foundation
import MusicKit
import os.log

final class DBSongMetadataParser {
    private let logger: Logger
    
    init(logger: Logger) {
        self.logger = logger
    }
    
    func parse(
        from playlistString: String,
        playlistID: String,
        progressHandler: ((Int) -> Void)? = nil
    ) async throws -> [DBSongMetadata] {
        logger.info("Parsing song metadata from string")
        let lines = playlistString.components(separatedBy: .newlines)
        var DBSongMetadatas: [DBSongMetadata] = []
        
        for (index, line) in lines.enumerated() {
            guard let (artist, title) = parseLine(line) else { continue }
            if let DBSongMetadata = await fetchDBSongMetadata(
                artist: artist,
                title: title,
                playlistID: playlistID
            ) {
                DBSongMetadatas.append(DBSongMetadata)
            }
            let progress = (index + 1) * 100 / lines.count
            progressHandler?(progress)
        }
        
        logger.info("Parsed song metadata successfully, count: \(DBSongMetadatas.count)")
        return DBSongMetadatas
    }
    
    private func parseLine(_ line: String) -> (artist: String, title: String)? {
        logger.debug("Processing line: \(line)")
        
        let cleanedLine = cleanLine(line)
        guard !cleanedLine.isEmpty else {
            logger.error("Invalid line format: \(line)")
            return nil
        }
        
        typealias ParsingOption = (format: String?, separator: String, artistFirst: Bool)
        
        let parsingOptions: [ParsingOption] = [
            (format: #"^\d+\.\s*\""#, separator: "\" by ", artistFirst: true),
            (format: #"^\d+\.\s*"#, separator: " by ", artistFirst: true),
            (format: #"^\d+\.\s*"#, separator: "–", artistFirst: true),
            (format: nil, separator: "-", artistFirst: true),
            (format: nil, separator: "ft.", artistFirst: false)
        ]
        
        for option in parsingOptions {
            if let metadata = parseFormattedLine(
                cleanedLine,
                format: option.format,
                separator: option.separator,
                artistFirst: option.artistFirst
            ) {
                return metadata
            }
        }
        
        logger.error("Could not parse line into a valid format: \(cleanedLine)")
        return nil
    }
    
    private func cleanLine(_ line: String) -> String {
        return line
            .replacingOccurrences(of: "\"", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func parseFormattedLine(
        _ line: String,
        format: String?,
        separator: String,
        artistFirst: Bool = true
    ) -> (artist: String, title: String)? {
        var modifiedLine = line
        
        if let format = format, let range = line.range(
            of: format,
            options: .regularExpression
        ) {
            modifiedLine = String(line[range.upperBound...])
        }
        
        let components = modifiedLine
            .split(separator: Substring(separator), maxSplits: 1)
            .map {
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
                    .replacingOccurrences(of: "\"", with: "")
            }
        guard components.count == 2 else { return nil }
        
        return artistFirst
        ? (String(components[0]), String(components[1]))
        : (String(components[1]), String(components[0]))
    }
    
    private func fetchDBSongMetadata(
        artist: String,
        title: String,
        playlistID: String
    ) async -> DBSongMetadata? {
        logger.debug("Fetching song metadata for title: \(title), artist: \(artist)")
        let searchRequest = MusicCatalogSearchRequest(
            term: "\(artist) \(title)",
            types: [Song.self]
        )
        
        do {
            let response = try await searchRequest.response()
            logger.debug("MusicKit search response received")
            
            if let song = response.songs.first {
                let artworkURL = song.artwork?.url(width: 300, height: 300)
                let album = song.albumTitle ?? "Unknown Album"
                let releaseDate = song.releaseDate
                let genreNames = song.genreNames
                let isExplicit = song.contentRating == .explicit
                let appleMusicID = song.id.rawValue
                let previewURL = song.previewAssets?.first?.url
                
                let DBSongMetadata = DBSongMetadata(
                    id: appleMusicID,
                    title: song.title,
                    artist: song.artistName,
                    album: album,
                    artworkURL: artworkURL,
                    releaseDate: releaseDate,
                    genreNames: genreNames,
                    isExplicit: isExplicit,
                    appleMusicID: appleMusicID,
                    previewURL: previewURL,
                    playlistID: playlistID
                )
                
                return DBSongMetadata
            } else {
                logger.warning("No song found for title: \(title), artist: \(artist)")
                return nil
            }
        } catch {
            logger.error("Error fetching song metadata: \(error.localizedDescription)")
            return nil
        }
    }
}
