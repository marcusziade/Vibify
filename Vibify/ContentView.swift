import SwiftUI

struct ContentView: View {
    
    @Bindable var viewModel = PlaylistViewModel()
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                TextField("Enter your music preference", text: $viewModel.prompt)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button {
                    Task { viewModel.fetchPlaylistSuggestion() }
                } label: {
                    Text("Get Playlist Suggestion")
                        .bold()
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading)
                .padding()
                
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(1.5)
                } else {
                    ForEach(viewModel.playlistSuggestion, id: \.self) { song in
                        Text(song)
                            .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                if !viewModel.playlistSuggestion.isEmpty {
                    Button(
                        viewModel.isAuthorizedForAppleMusic ? "Add to Apple Music" : "Authorize Apple Music",
                        action: {
                            if viewModel.isAuthorizedForAppleMusic {
                                viewModel.createAndAddPlaylistToAppleMusic()
                            } else {
                                Task {
                                    await viewModel.requestAppleMusicAuthorization()
                                }
                            }
                        }
                    )
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
            }
            .navigationBarTitle("Playlist Generator", displayMode: .large)
            .alert(isPresented: $viewModel.showingAlert) {
                Alert(title: Text("Playlist Generator"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}
