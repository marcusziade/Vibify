import SwiftUI

struct PlaylistGeneratorView: View {
    @Bindable var viewModel = PlaylistGeneratorVM()
    
    @State private var showAdvancedSearch = false
    @Bindable private var advancedSearchVM = AdvancedSearchCriteriaVM()
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                mainContentView
                    .blur(radius: viewModel.isLoading ? 5 : 0)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.isLoading)
                    .disabled(viewModel.isLoading)
                
                loaderView
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAdvancedSearch.toggle()
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            }
            .sheet(isPresented: $showAdvancedSearch) {
                AdvancedSearchCriteriaView(viewModel: advancedSearchVM) { updatedVM in
                    updatedVM.updateMainViewModel(viewModel)
                }
            }
            .alert(isPresented: $viewModel.showingAlert, content: alert)
            .navigationTitle("Playlist Generator")
        }
    }
}

// MARK: - Subviews and Components
private extension PlaylistGeneratorView {
    // Main content view
    var mainContentView: some View {
        ScrollView {
            VStack(spacing: .zero) {
                TextField("Explain your playlist configuration...", text: $viewModel.textPrompt)
                    .padding()
                getSuggestionButton
                songCardListView
                addToAppleMusicButton
                sharePlaylistButton
                Button("Surprise Me", action: viewModel.generateRandomPlaylist)
                .padding(.top, 8)
            }
        }
    }
    
    // Loader View
    var loaderView: some View {
        Group {
            if viewModel.isLoading {
                CustomProgressView(
                    progress: $viewModel.progress,
                    title: viewModel.isImporting ? "Importing" : "Generating"
                )
                .background(Color.white)
                .cornerRadius(8)
                .shadow(radius: 8)
            }
        }
        .transition(.move(edge: .top))
        .animation(.snappy, value: viewModel.isLoading)
    }
    
    // Get Suggestion Button
    var getSuggestionButton: some View {
        Button {
            withAnimation {
                viewModel.fetchPlaylistSuggestion()
            }
        } label: {
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
    }
    
    // Song Card List View
    var songCardListView: some View {
        Group {
            ForEach(viewModel.playlistSuggestion, id: \.title) { song in
                SongCardView(
                    song: song,
                    togglePlayback: viewModel.togglePlayback,
                    isPlaying: viewModel.isCurrentlyPlaying(song: song)
                )
            }
        }
    }
    
    // Add to Apple Music Button
    var addToAppleMusicButton: some View {
        Group {
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
    }
    
    // Share Playlist Button
    var sharePlaylistButton: some View {
        Button("Share Playlist", action: viewModel.sharePlaylist)
            .padding(.top, 8)
    }
    
    // Alert and Sheet
    func alert() -> Alert {
        Alert(title: Text("Error"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
    }
}

// MARK: - Preview
struct PlaylistGeneratorView_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistGeneratorView(viewModel: PlaylistGeneratorVM())
    }
}
