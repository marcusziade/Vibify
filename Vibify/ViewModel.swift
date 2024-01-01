import Foundation
import Observation
import StoreKit
import MediaPlayer
import MusicKit
import UIKit

@Observable
final class PlaylistViewModel {
    
    var isPlaying: Bool = false
    
    var prompt: String = "Give me 20 rock songs from the 90s"
    var playlistSuggestion: [SongMetadata] = []
    var isLoading: Bool = false
    var progress: Double = 0.0
    @MainActor var isAuthorizedForAppleMusic: Bool = false
    var showingAlert: Bool = false
    var alertMessage: String = ""
    
    init() {
        Task { await requestAppleMusicAuthorization() }
    }
    
    func isCurrentlyPlaying(song: SongMetadata) -> Bool {
        return currentlyPlayingSong?.title == song.title && isPlaying
    }
    
    @MainActor func fetchPlaylistSuggestion() {
        isLoading = true
        Task {
            do {
                let suggestions = try await playlistGenerator.fetchPlaylistSuggestion(prompt: prompt)
                playlistSuggestion = suggestions
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
            
            let playlistName = "Playlist \(Date.now.formatted(date: .abbreviated, time: .shortened))"
            isLoading = true
            progress = 0.0
            
            do {
                let playlist = try await appleMusicImporter.createPlaylist(named: playlistName)
                
                let result = await appleMusicImporter.addSongsToPlaylist(
                    playlist: playlist,
                    songs: self.playlistSuggestion,
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
        }
    }
    
    func togglePlayback(for song: SongMetadata) {
        if currentlyPlayingSong?.title == song.title && isPlaying {
            player.pause()
            isPlaying = false
        } else {
            playSong(song)
        }
    }
    
    private let playlistGenerator = PlaylistGenerator()
    private let appleMusicImporter = AppleMusicImporter()
    private let player = AVPlayer()
    private var currentlyPlayingSong: SongMetadata?
    
    @MainActor private func presentAlert(with message: String) {
        alertMessage = message
        showingAlert = true
    }
    
    private func playSong(_ song: SongMetadata) {
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
