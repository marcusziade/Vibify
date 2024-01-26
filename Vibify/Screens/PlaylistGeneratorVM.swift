import Foundation
import Combine
import StoreKit
import MediaPlayer
import MusicKit
import Observation
import SwiftUI

@Observable
final class PlaylistGeneratorVM {
    
    var textPrompt: String = ""
    var isPlaying: Bool = false
    var playlistSuggestion: [DBSongMetadata] = []
    var playlistArtworkURL: URL?
    var isFetchingPlaylist: Bool = false
    var isAddingToAppleMusic: Bool = false
    var isSharingPlaylist: Bool = false
    var isGeneratingRandomPlaylist: Bool = false
    var isGeneratingImage: Bool = false
    var showHistory: Bool = false
    var showServiceStatus: Bool = false
    var progress: Double = 0.0
    var isAuthorizedForAppleMusic: Bool = false
    var showingAlert: Bool = false
    var alertMessage: String = ""
    var searchCriteria = SongSearchCriteria()
    var selectedTheme: String = "Default"
    var isConfiguringSearch: Bool = true
    var showAdvancedSearch: Bool = false
    
    var selectedGenres: Set<String> = []
    
    let decadeRange: ClosedRange<Double> = 1860...Double(Date().year)
    let pastDecadeRange = (Date().year - 10)...Date().year
    
    var selectedGenre: String {
        get {
            searchCriteria.genreProportions.max(by: { $0.value < $1.value })?.key ?? ""
        }
        set {
            searchCriteria.genreProportions = [newValue: 1.0]
        }
    }
    
    /// Checks if anything is loading.
    var isLoading: Bool {
        isFetchingPlaylist || isAddingToAppleMusic || isSharingPlaylist || isGeneratingRandomPlaylist
    }
    
    let databaseManager: DatabaseManaging
    private(set) var appleMusicImporter: AppleMusicImporter
    
    init(
        networkService: NetworkService,
        databaseManager: DatabaseManaging,
        playlistGenerator: PlaylistGenerator,
        appleMusicImporter: AppleMusicImporter,
        dalleGenerator: DalleGenerator,
        player: AVPlayer = AVPlayer()
    ) {
        self.databaseManager = databaseManager
        self.playlistGenerator = playlistGenerator
        self.appleMusicImporter = appleMusicImporter
        self.dalleGenerator = dalleGenerator
        self.player = player
        
        Task { await requestAppleMusicAuthorization() }
    }
    
    func isCurrentlyPlaying(song: DBSongMetadata) -> Bool {
        return currentlyPlayingSong?.title == song.title && isPlaying
    }
    
    func fetchPlaylistSuggestion() async {
        playlistSuggestion = []
        playlistArtworkURL = nil
        currentPlaylistID = nil
        isFetchingPlaylist = true
        progress = .zero
        
        do {
            playlistSuggestion = try await playlistGenerator.fetchPlaylistSuggestion(
                criteria: textPrompt.isEmpty ? searchCriteria : textPrompt
            ) { [unowned self] newProgress in
                progress = Double(newProgress) / 100.0
            }
            
            isConfiguringSearch = false
            
            let primaryGenre = searchCriteria.genreProportions.max(by: { $0.value < $1.value })?.key ?? "No Genre"
            let playlist = DBPlaylist(
                title: primaryGenre,
                playlistID: UUID().uuidString,
                createdAt: Date.now,
                songs: playlistSuggestion
            )
            try databaseManager.insert(playlist: playlist)
            currentPlaylistID = playlist.id
        } catch let error as PlaylistGeneratorError {
            await MainActor.run {
                switch error {
                case .unauthorized:
                    presentAlert(with: "Unauthorized access. Please check your API key.")
                case .rateLimitExceeded:
                    presentAlert(with: "Rate limit exceeded. Please try again later.")
                case .missingAPIKey:
                    presentAlert(with: "Missing API key.")
                case .dataDecodingError:
                    presentAlert(with: "Failed to decode data.")
                case .invalidResponse, .invalidRequest, .unexpectedStatusCode:
                    presentAlert(with: "Network error occurred.")
                default:
                    presentAlert(with: "An unknown error occurred.")
                }
            }
        } catch {
            await MainActor.run {
                presentAlert(with: "An unexpected error occurred: \(error.localizedDescription)")
            }
        }
        
        isFetchingPlaylist = false
    }
    
    func generateDalleImage() async {
        isGeneratingImage = true
        
        let prompt = await dalleGenerator.dallePrompt(forInfo: playlistSuggestion.dallePrompt)
        
        debugPrint("Prompt: \(prompt)")
        
        do {
            let generatedArtworkURL = try await dalleGenerator.image(prompt: prompt, style: "natural")
            
            let localArtworkURL = try await downloadAndSaveImage(from: generatedArtworkURL)
            
            if let playlistID = currentPlaylistID {
                try databaseManager.updatePlaylistArtworkURL(
                    playlistID: playlistID,
                    artworkURL: localArtworkURL.absoluteString
                )
            }

            playlistArtworkURL = generatedArtworkURL
        } catch let error as DalleGeneratorError {
            await MainActor.run {
                switch error {
                case .missingAPIKey:
                    presentAlert(with: "Missing API key.")
                case .invalidRequest:
                    presentAlert(with: "Invalid request.")
                case .unexpectedStatusCode(let code):
                    presentAlert(with: "Unexpected status code: \(code)")
                case .networkFailure:
                    presentAlert(with: "Network failure.")
                case .dataDecodingError(let error):
                    presentAlert(with: "Failed to decode data: \(error)")
                case .serverError:
                    presentAlert(with: "Server error.")
                case .unknownError:
                    presentAlert(with: "An unknown error occurred.")
                case .invalidResponse:
                    presentAlert(with: "Invalid response.")
                case .invalidURL:
                    presentAlert(with: "Invalid URL.")
                case .promptTooLong:
                    presentAlert(with: "Prompt is too long.")
                }
            }
        } catch {
            await MainActor.run {
                presentAlert(with: "Failed to generate image: \(error.localizedDescription)")
            }
        }
        isGeneratingImage = false
    }

    @MainActor func requestAppleMusicAuthorization() async {
        isAuthorizedForAppleMusic = await appleMusicImporter.requestAppleMusicAccess()
    }
    
    func createAndAddPlaylistToAppleMusic() async {
        progress = 0.0
        guard !playlistSuggestion.isEmpty else {
            presentAlert(with: "No songs to add to the playlist.")
            return
        }
        isAddingToAppleMusic = true
        
        do {
            let playlistName = "Playlist \(Date.now.formatted(date: .abbreviated, time: .shortened))"
            let playlist = try await appleMusicImporter.createPlaylist(named: playlistName)
            let result = await appleMusicImporter.addSongsToPlaylist(
                playlist: playlist,
                songs: playlistSuggestion,
                progressHandler: { [unowned self] newProgress in
                    progress = newProgress
                }
            )
            switch result {
            case .success():
                presentAlert(with: "Songs added to the playlist successfully.")
            case .failure(let error):
                presentAlert(with: "Failed to add songs to the playlist: \(error.localizedDescription)")
            }
        } catch {
            presentAlert(with: "Failed to create playlist: \(error.localizedDescription)")
        }
        isAddingToAppleMusic = false
    }
    
    func generateRandomPlaylist() async {
        guard !isGeneratingRandomPlaylist else { return }
        isGeneratingRandomPlaylist = true
        progress = .zero
        
        // Perform async task here
        withAnimation(.snappy) {
            isConfiguringSearch = false
        }
        
        isGeneratingRandomPlaylist = false
    }

    func sharePlaylist() async {
        guard !isSharingPlaylist else { return }
        isSharingPlaylist = true
        // Perform share action here
        isSharingPlaylist = false
    }

    func togglePlayback(for song: DBSongMetadata) {
        if isCurrentlyPlaying(song: song) {
            player.pause()
            isPlaying = false
        } else {
            playSong(song)
        }
    }
    
    // MARK: Private
    
    private var currentlyPlayingSong: DBSongMetadata?
    private var currentPlaylistID: String?
    
    private let playlistGenerator: PlaylistGenerator
    private let dalleGenerator: DalleGenerator
    private let player: AVPlayer
    
    private func downloadAndSaveImage(from url: URL) async throws -> URL {
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw NSError(
                domain: "ImageDownloadError",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Failed to create image from downloaded data."]
            )
        }
        
        guard let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            throw NSError(
                domain: "FileSaveError",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Cannot find documents directory."]
            )
        }
        
        let fileURL = documentsDirectory.appendingPathComponent("\(UUID().uuidString).png")
        guard let imageData = image.pngData() else {
            throw NSError(
                domain: "ImageConversionError",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to PNG data."]
            )
        }
        
        try imageData.write(to: fileURL)
        return fileURL
    }

    private func presentAlert(with message: String) {
        alertMessage = message
        showingAlert = true
    }
    
    private func playSong(_ song: DBSongMetadata) {
        guard let url = song.previewURL else { return }
        if player.rate != 0 {
            player.pause()
        }
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        player.play()
        currentlyPlayingSong = song
        isPlaying = true
    }
}

extension PlaylistGeneratorVM {
    
    var searchSuggestions: [String] {
        return [
            "I want to listen to some rock music from the 70s",
            "Generate a playlist illustrating the greatness of video game soundtracks",
            "A playlist of songs that will make me cry",
            "I want to listen to some classical music, with an emphasis on piano",
            "Create a playlist featuring the best jazz tunes for a relaxing evening",
            "I'm looking for high-energy electronic dance music for my workout",
            "Generate a playlist of indie folk songs perfect for a road trip?",
            "I need a playlist of the top hip-hop hits from the 2000s",
            "Compile a list of ambient tracks ideal for meditation and relaxation",
            "I'm in the mood for some upbeat pop songs from the last decade"
        ]
    }
}
