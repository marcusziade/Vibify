import SwiftUI

struct PlaylistGeneratorView: View {
    @Bindable var viewModel = PlaylistGeneratorVM()
    
    @State private var showAdvancedSearch = false
    @Bindable private var advancedSearchVM = AdvancedSearchCriteriaVM()
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                mainContentView
                    .animation(.easeInOut(duration: 0.3), value: viewModel.isLoading)
                    .disabled(viewModel.isLoading)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAdvancedSearch.toggle()
                    } label: {
                        HStack {
                            Text("Advanced search")
                            Image(systemName: "slider.horizontal.3")
                        }
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

private extension PlaylistGeneratorView {
    
    var mainContentView: some View {
        ScrollView {
            VStack(spacing: 16) {
                TextField("Explain your playlist configuration...", text: $viewModel.textPrompt)
                    .padding()
                getSuggestionButton
                songCardListView
                addToAppleMusicButton
                sharePlaylistButton
                surpriseMeButton
            }
        }
    }
    
    var getSuggestionButton: some View {
        AsyncButton(
            title: "Get Playlist Suggestion",
            icon: "music.note.list",
            action: viewModel.fetchPlaylistSuggestion,
            isLoading: $viewModel.isFetchingPlaylist,
            colors: [.purple, .pink]
        )
    }
    
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
    
    var addToAppleMusicButton: some View {
        Group {
            if !viewModel.playlistSuggestion.isEmpty && viewModel.isAuthorizedForAppleMusic {
                AsyncButton(
                    title: "Add to Apple Music",
                    icon: "music.note.list",
                    action: viewModel.createAndAddPlaylistToAppleMusic,
                    isLoading: $viewModel.isAddingToAppleMusic,
                    colors: [.purple, .pink]
                )
            }
        }
    }
    
    var sharePlaylistButton: some View {
        Group {
            if !viewModel.playlistSuggestion.isEmpty {
                AsyncButton(
                    title: "Share Playlist",
                    icon: "square.and.arrow.up",
                    action: viewModel.sharePlaylist,
                    isLoading: $viewModel.isSharingPlaylist,
                    colors: [.blue, .cyan]
                )
            }
        }
    }
    
    var surpriseMeButton: some View {
        AsyncButton(
            title: "Surprise Me",
            icon: "shuffle",
            action: {}, //viewModel.fetchSurprisePlaylist,
            isLoading: $viewModel.isGeneratingRandomPlaylist,
            colors: [.blue, .cyan]
        )
    }
    
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
