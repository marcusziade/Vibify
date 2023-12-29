import Foundation

final class PlaylistViewModel: ObservableObject {
    @Published var prompt: String = "Give me 3 dance songs from 2010"
    @Published var playlistSuggestion: [String] = []
    @Published var isLoading: Bool = false
    @Published var isAuthorizedForAppleMusic: Bool = false
    @Published var showingAlert: Bool = false
    @Published var alertMessage: String = ""
    
    private let playlistGenerator = PlaylistGenerator()
    private let appleMusicImporter = AppleMusicImporter()
    
    func fetchPlaylistSuggestion() {
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
    
    func requestAppleMusicAuthorization() {
        appleMusicImporter.requestAppleMusicAccess { [unowned self] authorized in
            isAuthorizedForAppleMusic = authorized
        }
    }
    
    func createAndAddPlaylistToAppleMusic() {
        // Ensure we have song titles to add.
        guard !playlistSuggestion.isEmpty else {
            presentAlert(with: "No songs to add to the playlist.")
            return
        }
        
        let playlistName = "Playlist \(Date.now.formatted(date: .abbreviated, time: .shortened))"
        
        appleMusicImporter.createPlaylist(named: playlistName) { [unowned self] playlist, error in
            guard let playlist, error == nil else {
                presentAlert(with: "Failed to create playlist: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            appleMusicImporter.addSongsToPlaylist(
                playlist: playlist,
                songTitles: self.playlistSuggestion
            ) { [unowned self] success, error in
                let alertMessage = success
                ? "Songs added to the playlist successfully."
                : "Failed to add songs to the playlist: \(error?.localizedDescription ?? "Unknown error")"
                
                presentAlert(with: alertMessage)
            }
        }
    }
    
    private func presentAlert(with message: String) {
        alertMessage = message
        showingAlert = true
    }
}
