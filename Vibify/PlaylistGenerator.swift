import Foundation
import MusicKit
import os.log

struct OpenAIRequest: Codable {
    let model: String
    let prompt: String
    let maxTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case model
        case prompt
        case maxTokens = "max_tokens"
    }
}

struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let text: String
    }
}

enum PlaylistGeneratorError: Error {
    case urlSessionError(Error)
    case dataDecodingError(Error)
    case invalidResponse
    case unauthorized
    case rateLimitExceeded
    case missingAPIKey
}

final class PlaylistGenerator {
    
    func fetchPlaylistSuggestion(prompt: String) async throws -> [SongMetadata] {
        logger.info("Starting fetchPlaylistSuggestion for prompt: \(prompt)")
        
        guard let apiKey = openAIKey else {
            logger.error("Missing API key")
            throw PlaylistGeneratorError.missingAPIKey
        }
        
#if targetEnvironment(simulator) || DEBUG
        let simulatedResponse = "\n\n1. \"Only Girl (In the World)\" – Rihanna\n2. \"Dynamite\" – Taio Cruz \n3. \"California Gurls\" – Katy Perry ft. Snoop Dogg\n4. \"Club Can\'t Handle Me\" – Flo Rida ft. David Guetta\n5. \"Hey, Soul Sister\" – Train\n6. \"Tik Tok\" – Kesha\n7. \"Like a G6\" – Far East Movement ft. The Cataracs & Dev\n8. \"DJ Got Us Fallin\' in Love\" – Usher ft. Pitbull\n9. \"Grenade\" – Bruno Mars\n10. \"OMG\" – Usher ft. Will.i.am\n11. \"Only\" – Nicki Minaj\n12. \"Just the Way You Are\" – Bruno Mars\n13. \"We No Speak Americano\" – Yolanda Be Cool & DCUP \n14. \"Bad Romance\" – Lady Gaga\n15. \"Nothin\' on You\" – B.o.B ft. Bruno Mars\n16. \"Firework\" – Katy Perry\n17. \"Unstoppable\" – Foxy Brown ft. Swizz Beatz\n18. \"Airplanes\" – B.o.B ft. Hayley Williams\n19. \"On the Floor\" – Jennifer Lopez ft. Pitbull\n20. \"Teenage Dream\" – Katy Perry\n21. \"Love the Way You Lie\" – Eminem ft. Rihanna\n22. \"Give Me Everything\" – Pitbull ft. Ne-Yo\n23. \"E.T.\" – Katy Perry ft. Kanye West\n24. \"Rolling in the Deep\" – Adele\n25. \"Hey Baby (Drop It to the Floor)\" – Pitbull ft. T-Pain"
        return try await parseSongMetadata(from: simulatedResponse)
#else
        guard let url = URL(string: "https://api.openai.com/v1/completions") else {
            logger.error("Invalid URL for API request")
            throw PlaylistGeneratorError.invalidResponse
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let body = OpenAIRequest(model: "text-davinci-003", prompt: prompt, maxTokens: 500)
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
            logger.info("Request body encoded successfully")
        } catch {
            logger.error("JSON Encoding Error: \(error.localizedDescription)")
            throw PlaylistGeneratorError.dataDecodingError(error)
        }
        
        do {
            logger.info("Sending request to OpenAI API")
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("Invalid response received")
                throw PlaylistGeneratorError.invalidResponse
            }
            
            logger.info("Received response with status code: \(httpResponse.statusCode)")
            
            switch httpResponse.statusCode {
            case 200:
                do {
                    let decodedResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                    guard let firstChoice = decodedResponse.choices.first else {
                        logger.error("No choices found in response")
                        throw PlaylistGeneratorError.invalidResponse
                    }
                    debugPrint(firstChoice.text)
                    return try await parseSongMetadata(from: firstChoice.text)
                } catch {
                    logger.error("Error decoding response: \(error.localizedDescription)")
                    throw PlaylistGeneratorError.dataDecodingError(error)
                }
            case 401:
                logger.error("Unauthorized: Invalid API Key")
                throw PlaylistGeneratorError.unauthorized
            case 429:
                logger.error("Rate limit exceeded")
                throw PlaylistGeneratorError.rateLimitExceeded
            default:
                logger.error("Unexpected status code received: \(httpResponse.statusCode)")
                throw PlaylistGeneratorError.invalidResponse
            }
        } catch {
            logger.error("URL Session error: \(error.localizedDescription)")
            throw PlaylistGeneratorError.urlSessionError(error)
        }
#endif
    }
    
    private func parseSongMetadata(from playlistString: String) async throws -> [SongMetadata] {
        logger.info("Parsing song metadata from string")
        let lines = playlistString.components(separatedBy: .newlines)
        var songMetadatas: [SongMetadata] = []
        
        for line in lines {
            logger.debug("Processing line: \(line)")
            
            // Remove initial numbering and trim spaces
            let trimmedLine = line
                .drop(while: { !$0.isLetter })  // Drop the numbering and periods
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard !trimmedLine.isEmpty else {
                logger.error("Invalid line format: \(line)")
                continue
            }
            
            // Splitting the line based on the hyphen
            let titleArtistComponents = trimmedLine
                .split(separator: "–", maxSplits: 1)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .map { $0.replacingOccurrences(of: "\"", with: "") } // Remove quotes
            
            guard titleArtistComponents.count == 2 else {
                logger.error("Invalid title-artist format: \(trimmedLine)")
                continue
            }
            
            let title = String(titleArtistComponents[0])
            let artist = String(titleArtistComponents[1])
            
            logger.debug("Fetching song metadata for title: \(title), artist: \(artist)")
            let searchRequest = MusicCatalogSearchRequest(
                term: "\(title) \(artist)",
                types: [Song.self]
            )
            let response = try await searchRequest.response()
            logger.debug("MusicKit search response received")
            
            if let song = response.songs.first {
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
                
                songMetadatas.append(songMetadata)            } else {
                logger.warning("No song found for title: \(title), artist: \(artist)")
            }
        }
        
        logger.info("Parsed song metadata successfully, count: \(songMetadatas.count)")
        return songMetadatas
    }
    
    
    private var openAIKey: String? {
        ProcessInfo.processInfo.environment["API_KEY"]
    }
    
    private let logger = Logger(subsystem: "com.marcusziade.Vibify.app", category: "Networking")
}
