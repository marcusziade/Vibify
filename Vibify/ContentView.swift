import SwiftUI

struct ContentView: View {
    @State private var prompt: String = ""
    @State private var playlistSuggestion: String = ""
    @State private var isLoading: Bool = false
    
    private let playlistGenerator = PlaylistGenerator()
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter your music preference", text: $prompt)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Get Playlist Suggestion") {
                    Task {
                        isLoading = true
                        do {
                            playlistSuggestion = try await playlistGenerator.fetchPlaylistSuggestion(prompt: prompt)
                        } catch {
                            playlistSuggestion = "Error: \(error.localizedDescription)"
                        }
                        isLoading = false
                    }
                }
                .disabled(isLoading)
                
                if isLoading {
                    ProgressView()
                } else {
                    Text(playlistSuggestion)
                        .padding()
                }
            }
            .navigationBarTitle("Playlist Generator")
        }
    }
}

#Preview {
    ContentView()
}
