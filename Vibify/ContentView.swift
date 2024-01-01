import SwiftUI

struct ContentView: View {
    
    @Bindable var viewModel = PlaylistViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter your music preference", text: $viewModel.prompt)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    Task { viewModel.fetchPlaylistSuggestion() }
                }) {
                    Label("Get Playlist Suggestion", systemImage: "music.note.list")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .disabled(viewModel.isLoading)
                .padding(.horizontal)
                
                if viewModel.isLoading {
                    CustomProgressView(progress: $viewModel.progress)
                        .frame(width: 80, height: 80)
                        .padding()
                        .transition(.scale)
                } else {
                    ScrollView {
                        ForEach(viewModel.playlistSuggestion, id: \.title) { song in
                            SongCardView(
                                song: song,
                                togglePlayback: viewModel.togglePlayback,
                                isPlaying: viewModel.isCurrentlyPlaying(song: song)
                            )
                        }
                    }
                }
                
                Spacer()
                
                if !viewModel.playlistSuggestion.isEmpty && viewModel.isAuthorizedForAppleMusic {
                    Button(action: viewModel.createAndAddPlaylistToAppleMusic) {
                        Text("Add to Apple Music")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarTitle("Playlist Generator", displayMode: .large)
            .alert(isPresented: $viewModel.showingAlert) {
                Alert(title: Text("Playlist Generator"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}

#Preview {
    ContentView(viewModel: PlaylistViewModel())
}
