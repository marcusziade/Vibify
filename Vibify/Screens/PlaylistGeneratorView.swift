import SwiftUI

struct PlaylistGeneratorView: View {
    @Bindable var viewModel = PlaylistGeneratorVM()
    @Bindable private var advancedSearchVM = AdvancedSearchCriteriaVM()
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                mainContentView
                    .disabled(viewModel.isLoading)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showAdvancedSearch.toggle()
                        viewModel.isConfiguringSearch = true
                    } label: {
                        VStack(alignment: .trailing, spacing: .zero) {
                            Image(systemName: "slider.horizontal.3")
                            Text("Advanced search")
                                .font(.callout)
                        }
                        .foregroundColor(.primary)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        viewModel.showHistory.toggle()
                    } label: {
                        VStack(alignment: .leading, spacing: .zero) {
                            Image(systemName: "clock")
                            Text("History")
                                .font(.callout)
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showAdvancedSearch) {
                AdvancedSearchCriteriaView(viewModel: advancedSearchVM) { updatedVM in
                    updatedVM.updateMainViewModel(viewModel)
                }
            }
            .sheet(isPresented: $viewModel.showHistory) {
                PlaylistHistoryView(
                    viewModel: PlaylistHistoryViewModel(
                        dbManager: viewModel.databaseManager
                    )
                )
            }
            .alert(isPresented: $viewModel.showingAlert, content: alert)
            .navigationTitle("Echo") // TODO: Remember to call gpt-vision "Vision"
        }
    }
}

private extension PlaylistGeneratorView {
    
    var mainContentView: some View {
        ScrollView {
            VStack(spacing: 16) {
                searchView
                getSuggestionButton
                songCardListView
                addToAppleMusicButton
                sharePlaylistButton
                surpriseMeButton
            }
        }
    }
    
    var searchView: some View {
        Group {
            if viewModel.isConfiguringSearch {
                TextEditor(text: $viewModel.textPrompt)
                    .frame(height: 100)
                    .font(.body)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary, lineWidth: 1)
                    )
                    .padding()
                
                Text(searchFieldText)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding()
                    .onTapGesture {
                        hideKeyboard()
                    }
            }
        }
    }
    
    var getSuggestionButton: some View {
        Group {
            if viewModel.isConfiguringSearch {
                AsyncButton(
                    title: "Get Playlist Suggestion",
                    icon: "music.note.list",
                    action: viewModel.fetchPlaylistSuggestion,
                    isLoading: $viewModel.isFetchingPlaylist,
                    colors: [.purple, .pink],
                    progress: $viewModel.progress
                )
            }
        }
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
                    colors: [.purple, .pink],
                    progress: $viewModel.progress
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
                    colors: [.blue, .cyan],
                    progress: $viewModel.progress
                )
            }
        }
    }
    
    var surpriseMeButton: some View {
        Group {
            if viewModel.isConfiguringSearch {
                AsyncButton(
                    title: "Surprise Me",
                    icon: "shuffle",
                    action: {}, //viewModel.fetchSurprisePlaylist,
                    isLoading: $viewModel.isGeneratingRandomPlaylist,
                    colors: [.blue, .cyan], progress: $viewModel.progress
                )
            }
        }
    }
    
    private var searchFieldText: String {
        if viewModel.isConfiguringSearch {
            """
What kind of playlist would you like to generate?

Examples:

- "I want to listen to some rock music from the 70s"

- "Generate a playlist illustrating the greatness of video game soundtracks"

- "A playlist of songs that will make me cry"

- "I want to listen to some classical music, with an emphasis on piano"

- "Create a playlist featuring the best jazz tunes for a relaxing evening"

- "I'm looking for high-energy electronic dance music for my workout"

- "Generate a playlist of indie folk songs perfect for a road trip?"

- "I need a playlist of the top hip-hop hits from the 2000s"

- "Compile a list of ambient tracks ideal for meditation and relaxation"

- "I'm in the mood for some upbeat pop songs from the last decade"
"""
        } else {
            ""
        }
    }
    
    func alert() -> Alert {
        Alert(
            title: Text(viewModel.alertMessage),
            dismissButton: .default(Text("OK"))
        )
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

// MARK: - Preview
struct PlaylistGeneratorView_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistGeneratorView(viewModel: PlaylistGeneratorVM())
    }
}
