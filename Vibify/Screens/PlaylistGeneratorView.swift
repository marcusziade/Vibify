import CachedAsyncImage
import SwiftUI

struct PlaylistGeneratorView: View {
    @Bindable var viewModel: PlaylistGeneratorVM
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
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.primary)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        viewModel.showHistory.toggle()
                    } label: {
                        Image(systemName: "clock")
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
                        dbManager: viewModel.databaseManager, 
                        appleMusicImporter: viewModel.appleMusicImporter
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
                getSuggestionButton.padding(.top, 32)
                songCardListView
                addToAppleMusicButton
                addToSpotifyButton
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
                    .clipped()
                    .cornerRadius(8)
                    .shadow(color: .secondary, radius: 8)
                    .padding()
                
                Text("What kind of playlist would you like to generate?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .onTapGesture {
                        hideKeyboard()
                    }
                
                ForEach(viewModel.searchSuggestions, id: \.self) { suggestion in
                    Button {
                        viewModel.textPrompt = suggestion
                    } label: {
                        Text(suggestion)
                            .font(.caption)
                            .fontDesign(.rounded)
                            .foregroundColor(.primary)
                        
                    }
                }
                .padding(.horizontal, 32)
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
            if !viewModel.playlistSuggestion.isEmpty {
                VStack {
                    ForEach(viewModel.playlistSuggestion, id: \.title) { song in
                        SongCardView(
                            song: song,
                            togglePlayback: viewModel.togglePlayback,
                            isPlaying: viewModel.isCurrentlyPlaying(song: song)
                        )
                    }
                    
                    if let url = viewModel.playlistArtworkURL {
                        CachedAsyncImage(url: url)
                            .frame(width: 300, height: 300)
                            .cornerRadius(8)
                            .shadow(color: .secondary, radius: 8)
                            .padding()
                    } else {
                        AsyncButton(
                            title: "Generate Dalle Image",
                            icon: "photo",
                            action: viewModel.generateDalleImage,
                            isLoading: $viewModel.isGeneratingImage,
                            colors: [.blue, .cyan],
                            progress: $viewModel.progress
                        )
                    }
                }
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
    
    var addToSpotifyButton: some View {
        Group {
            if !viewModel.playlistSuggestion.isEmpty { // && viewModel.isAuthorizedForSpotify {
                AsyncButton(
                    title: "Add to Spotify",
                    icon: "music.note.list",
                    action: {},// viewModel.createAndAddPlaylistToSpotify,
                    isLoading: $viewModel.isAddingToAppleMusic,
                    colors: [.green, darkGreen],
                    progress: $viewModel.progress
                )
            }
        }
    }
    
    var darkGreen: Color {
        Color(red: 0.0, green: 0.6, blue: 0.0)
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
