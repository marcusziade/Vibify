import Foundation
import Combine
import StoreKit
import MediaPlayer
import MusicKit
import Observation

@Observable
final class PlaylistViewModel {
    
    var isPlaying: Bool = false
    var playlistSuggestion: [DBSongMetadata] = []
    var isLoading: Bool = false
    var isImporting: Bool = false
    var showHistory: Bool = false
    var progress: Double = 0.0
    var isAuthorizedForAppleMusic: Bool = false
    var showingAlert: Bool = false
    var alertMessage: String = ""
    var searchCriteria = SongSearchCriteria()
    
    let genreList = ["Rock", "Pop", "Jazz", "Classical", "Hip-Hop", "Electronic"]
    let decadeRange: ClosedRange<Double> = 1860...Double(Date().year)
    
    private var currentlyPlayingSong: DBSongMetadata?
    
    private let databaseManager: DatabaseManager
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
    
    @MainActor func fetchPlaylistSuggestion() {
        guard !isLoading else { return }
        playlistSuggestion = []
        isLoading = true
        progress = .zero
        
        Task { [unowned self] in
            do {
                playlistSuggestion = try await playlistGenerator.fetchPlaylistSuggestion(
                    criteria: searchCriteria
                ) { [unowned self] newProgress in
                    progress = Double(newProgress) / 100.0
                }
                
                let playlist = DBPlaylist(
                    playlistID: UUID().uuidString,
                    createdAt: Date.now,
                    songs: playlistSuggestion
                )
                try databaseManager.insert(playlist: playlist)
            } catch {
                debugPrint(error)
                presentAlert(with: "Failed to generate playlist: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }
    
    @MainActor func requestAppleMusicAuthorization() async {
        isAuthorizedForAppleMusic = await appleMusicImporter.requestAppleMusicAccess()
    }
    
    func createAndAddPlaylistToAppleMusic() {
        Task {
            guard !playlistSuggestion.isEmpty else {
                await presentAlert(with: "No songs to add to the playlist.")
                return
            }
            isLoading = true
            isImporting = true
            progress = 0.0
            
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
                isLoading = false
                switch result {
                case .success():
                    await presentAlert(with: "Songs added to the playlist successfully.")
                case .failure(let error):
                    await presentAlert(with: "Failed to add songs to the playlist: \(error.localizedDescription)")
                }
            } catch {
                isLoading = false
                await presentAlert(with: "Failed to create playlist: \(error.localizedDescription)")
            }
            
            isImporting = false
        }
    }
    
    func togglePlayback(for song: DBSongMetadata) {
        if isCurrentlyPlaying(song: song) {
            player.pause()
            isPlaying = false
        } else {
            playSong(song)
        }
    }
    
    @MainActor private func presentAlert(with message: String) {
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
