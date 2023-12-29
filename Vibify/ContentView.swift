import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = PlaylistViewModel()
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                TextField("Enter your music preference", text: $viewModel.prompt)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: viewModel.fetchPlaylistSuggestion) {
                    Text("Get Playlist Suggestion")
                        .bold()
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(viewModel.isLoading)
                .padding(.horizontal)
                
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
                
                if viewModel.isAuthorizedForAppleMusic {
                    Button("Add to Apple Music", action: viewModel.createAndAddPlaylistToAppleMusic)
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.horizontal)
                } else {
                    Button("Authorize Apple Music", action: viewModel.requestAppleMusicAuthorization)
                        .buttonStyle(SecondaryButtonStyle())
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
