import SwiftUI

struct ContentView: View {
    @State private var prompt: String = "Give me 3 dance songs from 2010"
    @State private var playlistSuggestion: [String] = []
    @State private var isLoading: Bool = false
    @State private var isAuthorizedForAppleMusic: Bool = false
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""
    
    private let playlistGenerator = PlaylistGenerator()
    private let appleMusicImporter = AppleMusicImporter()
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                TextField("Enter your music preference", text: $prompt)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: fetchPlaylistSuggestion) {
                    Text("Get Playlist Suggestion")
                        .bold()
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(isLoading)
                .padding(.horizontal)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(1.5)
                } else {
                    ForEach(playlistSuggestion, id: \.self) { song in
                        Text(song)
                            .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                if isAuthorizedForAppleMusic {
                    Button("Add to Apple Music", action: createAndAddPlaylistToAppleMusic)
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.horizontal)
                } else {
                    Button("Authorize Apple Music", action: requestAppleMusicAuthorization)
                        .buttonStyle(SecondaryButtonStyle())
                        .padding(.horizontal)
                }
            }
            .navigationBarTitle("Playlist Generator", displayMode: .large)
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Playlist Generator"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func fetchPlaylistSuggestion() {
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
    
    private func requestAppleMusicAuthorization() {
        appleMusicImporter.requestAppleMusicAccess { authorized in
            isAuthorizedForAppleMusic = authorized
        }
    }
    
    private func createAndAddPlaylistToAppleMusic() {
        // Ensure we have song titles to add.
        guard !playlistSuggestion.isEmpty else {
            presentAlert(with: "No songs to add to the playlist.")
            return
        }
        
        // Create a playlist with a unique name, e.g., using the current timestamp.
        let playlistName = "Playlist \(Date())"
        
        // Create the playlist.
        appleMusicImporter.createPlaylist(named: playlistName) { playlist, error in
            guard let playlist = playlist, error == nil else {
                presentAlert(with: "Failed to create playlist: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Add the songs to the new playlist.
            appleMusicImporter.addSongsToPlaylist(playlist: playlist, songTitles: self.playlistSuggestion) { success, error in
                if success {
                    presentAlert(with: "Songs added to the playlist successfully.")
                } else {
                    presentAlert(with: "Failed to add songs to the playlist: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    private func presentAlert(with message: String) {
        alertMessage = message
        showingAlert = true
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.blue)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

