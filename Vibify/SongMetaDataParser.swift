import Foundation
import MusicKit
import os.log

final class SongMetadataParser {
    private let logger: Logger
    
    init(logger: Logger) {
        self.logger = logger
    }
    
    func parse(from playlistString: String) async throws -> [SongMetadata] {
        logger.info("Parsing song metadata from string")
        let lines = playlistString.components(separatedBy: .newlines)
        var songMetadatas: [SongMetadata] = []
        
        for line in lines {
            guard let (artist, title) = parseLine(line) else { continue }
            if let songMetadata = await fetchSongMetadata(artist: artist, title: title) {
                songMetadatas.append(songMetadata)
            }
        }
        
        logger.info("Parsed song metadata successfully, count: \(songMetadatas.count)")
        return songMetadatas
    }
    
    private func parseLine(_ line: String) -> (artist: String, title: String)? {
        logger.debug("Processing line: \(line)")
        
        let cleanedLine = cleanLine(line)
        guard !cleanedLine.isEmpty else {
            logger.error("Invalid line format: \(line)")
            return nil
        }
        
        if let metadata = parseFormattedLine(cleanedLine, format: #"^\d+\.\s*"#, separator: "–") {
            return metadata
        }
        
        if let metadata = parseFormattedLine(cleanedLine, format: nil, separator: "-") {
            return metadata
        }
        
        if let metadata = parseFormattedLine(cleanedLine, format: nil, separator: "ft.", artistFirst: false) {
            return metadata
        }
        
        logger.error("Could not parse line into a valid format: \(cleanedLine)")
        return nil
    }
    
    private func cleanLine(_ line: String) -> String {
        return line.replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func parseFormattedLine(_ line: String, format: String?, separator: String, artistFirst: Bool = true) -> (artist: String, title: String)? {
        var modifiedLine = line
        
        if let format = format, let range = line.range(of: format, options: .regularExpression) {
            modifiedLine = String(line[range.upperBound...])
        }
        
        let components = modifiedLine.split(separator: Substring(separator), maxSplits: 1).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        guard components.count == 2 else { return nil }
        
        return artistFirst ? (String(components[0]), String(components[1])) : (String(components[1]), String(components[0]))
    }
    
    private func fetchSongMetadata(artist: String, title: String) async -> SongMetadata? {
        logger.debug("Fetching song metadata for title: \(title), artist: \(artist)")
        let searchRequest = MusicCatalogSearchRequest(
            term: "\(artist) \(title)",
            types: [Song.self]
        )
        
        do {
            let response = try await searchRequest.response()
            logger.debug("MusicKit search response received")
            
            if let song = response.songs.first {
                // Construct and return SongMetadata from the song
                let artworkURL = song.artwork?.url(width: 300, height: 300)
                let album = song.albumTitle ?? "Unknown Album"
                let releaseDate = song.releaseDate
                let genreNames = song.genreNames
                let isExplicit = song.contentRating == .explicit
                let appleMusicID = song.id
                
                let songMetadata = SongMetadata(
                    title: song.title,
                    artist: song.artistName,
                    album: album,
                    artworkURL: artworkURL,
                    releaseDate: releaseDate,
                    genreNames: genreNames,
                    isExplicit: isExplicit,
                    appleMusicID: appleMusicID
                )
                
                return songMetadata
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
