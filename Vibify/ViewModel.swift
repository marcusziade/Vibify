import Foundation
import Observation

@Observable
final class PlaylistViewModel {
    
    var prompt: String = "Give me 3 dance songs from 2010"
    var playlistSuggestion: [String] = []
    var isLoading: Bool = false
    @MainActor var isAuthorizedForAppleMusic: Bool = false
    var showingAlert: Bool = false
    var alertMessage: String = ""
    
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
                // Handle errors appropriately
            }
            isLoading = false
        }
    }
    
    @MainActor func requestAppleMusicAuthorization() async {
        isAuthorizedForAppleMusic = await appleMusicImporter.requestAppleMusicAccess()
    }
    
    func createAndAddPlaylistToAppleMusic() {
        Task {
            // Ensure we have song titles to add.
            guard !playlistSuggestion.isEmpty else {
                await presentAlert(with: "No songs to add to the playlist.")
                return
            }
            
            let playlistName = "Playlist \(Date.now.formatted(date: .abbreviated, time: .shortened))"
            
            do {
                let playlist = try await appleMusicImporter.createPlaylist(
                    named: playlistName
                )
                let result = await appleMusicImporter.addSongsToPlaylist(
                    playlist: playlist,
                    songTitles: self.playlistSuggestion
                )
                
                switch result {
                case .success():
                    await presentAlert(with: "Songs added to the playlist successfully.")
                case .failure(let error):
                    await presentAlert(with: "Failed to add songs to the playlist: \(error.localizedDescription)")
                }
            } catch {
                await presentAlert(with: "Failed to create playlist: \(error.localizedDescription)")
            }
        }
    }
    
    private let playlistGenerator = PlaylistGenerator()
    private let appleMusicImporter = AppleMusicImporter()
    
    @MainActor private func presentAlert(with message: String) {
        alertMessage = message
        showingAlert = true
    }
}
