import Foundation
import Observation
import StoreKit
import MediaPlayer
import MusicKit

@Observable
final class PlaylistViewModel {
    
    var prompt: String = "Give me 20 rock songs from the 90s"
    var playlistSuggestion: [SongMetadata] = []
    var isLoading: Bool = false
    var progress: Double = 0.0
    @MainActor var isAuthorizedForAppleMusic: Bool = false
    var showingAlert: Bool = false
    var alertMessage: String = ""
    
    private let playlistGenerator = PlaylistGenerator()
    private let appleMusicImporter = AppleMusicImporter()
    
    init() {
        Task { await requestAppleMusicAuthorization() }
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
    
    @MainActor private func presentAlert(with message: String) {
        alertMessage = message
        showingAlert = true
    }
}
