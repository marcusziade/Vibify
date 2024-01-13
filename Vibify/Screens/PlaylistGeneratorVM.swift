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
    var isFetchingPlaylist: Bool = false
    var isAddingToAppleMusic: Bool = false
    var isSharingPlaylist: Bool = false
    var isGeneratingRandomPlaylist: Bool = false
    var showHistory: Bool = false
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
    
    private var currentlyPlayingSong: DBSongMetadata?
    
    let databaseManager: DatabaseManager
    private let playlistGenerator: PlaylistGenerator
    private let appleMusicImporter: AppleMusicImporter
    private let player: AVPlayer
    
    init(
        databaseManager: DatabaseManager = DatabaseManager(),
        playlistGenerator: PlaylistGenerator = PlaylistGenerator(),
        appleMusicImporter: AppleMusicImporter = AppleMusicImporter(),
        player: AVPlayer = AVPlayer()
    ) {
        self.databaseManager = databaseManager
        self.playlistGenerator = playlistGenerator
        self.appleMusicImporter = appleMusicImporter
        self.player = player
        Task { await requestAppleMusicAuthorization() }
    }
    
    func isCurrentlyPlaying(song: DBSongMetadata) -> Bool {
        return currentlyPlayingSong?.title == song.title && isPlaying
    }
    
    func fetchPlaylistSuggestion() async {
        playlistSuggestion = []
        isFetchingPlaylist = true
        progress = .zero
        
        do {
            playlistSuggestion = try await playlistGenerator.fetchPlaylistSuggestion(
                criteria: searchCriteria
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
        } catch {
            debugPrint(error)
            await MainActor.run {
                presentAlert(with: "Failed to generate playlist: \(error.localizedDescription)")
            }
        }
        isFetchingPlaylist = false
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
