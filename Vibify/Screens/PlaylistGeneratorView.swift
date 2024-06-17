import CachedAsyncImage
import SwiftData
import SwiftUI

struct PlaylistGeneratorView: View {
    
    @Environment(SpotifyService.self) var spotifyService
    @Environment(\.modelContext) var modelContext
    @Query(sort: \DBPlaylist.createdAt) var playlists: [DBPlaylist]
    
    @Bindable var viewModel: PlaylistGeneratorVM
    @Bindable private var advancedSearchVM = AdvancedSearchCriteriaVM()
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
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
                .disabled(viewModel.isLoading)
                .scrollIndicators(.hidden)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button {
                            withAnimation {
                                viewModel.selectedVisionImageData = nil
                                viewModel.playlistSuggestion = []
                                viewModel.isConfiguringSearch = true
                            }
                        } label: {
                            Text("Reset")
                        }
                        
                        Button {
                            viewModel.isVisionPickerPresented.toggle()
                        } label: {
                            Image(systemName: "cpu")
                        }
                        if viewModel.selectedVisionImageData == nil {
                            Button {
                                viewModel.showAdvancedSearch.toggle()
                                viewModel.isConfiguringSearch = true
                            } label: {
                                Image(systemName: "slider.horizontal.3")
                            }
                        } else {
                            Button {
                                withAnimation {
                                    viewModel.selectedVisionImageData = nil
                                }
                            } label: {
                                Image(systemName: "pencil")
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Button {
                            viewModel.showHistory.toggle()
                        } label: {
                            Image(systemName: "clock")
                                .foregroundColor(.primary)
                        }
                        Button {
                            viewModel.showServiceStatus.toggle()
                        } label: {
                            Image(systemName: "dot.radiowaves.up.forward")
                                .foregroundColor(.primary)
                        }
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
                        appleMusicImporter: viewModel.appleMusicImporter
                    )
                )
            }
            .sheet(isPresented: $viewModel.showServiceStatus) {
                ServiceStatusView()
            }
            .sheet(isPresented: $viewModel.isVisionPickerPresented) {
                PhotoPicker(selectedImageData: $viewModel.selectedVisionImageData)
            }
            .alert(isPresented: $viewModel.showingAlert, content: alert)
            .navigationTitle(viewModel.selectedVisionImageData == nil ? "Echo" : "Vision")
        }
    }
}

private extension PlaylistGeneratorView {
    
    var searchView: some View {
        Group {
            if
                let imageData = viewModel.selectedVisionImageData,
                let image = UIImage(data: imageData)
            {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding(.vertical)
                    .animation(.snappy, value: viewModel.selectedVisionImageData)
            } else if viewModel.isConfiguringSearch {
                Group {
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
                .animation(.snappy, value: viewModel.selectedVisionImageData)
            }
        }
    }
    
    var getSuggestionButton: some View {
        Group {
            if viewModel.isConfiguringSearch {
                AsyncButton(
                    title: "Get Playlist Suggestion",
                    icon: "music.note.list",
                    action: {
                        Task {
                            await fetchPlaylistSuggestion()
                        }
                    },
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
                    
                    if let url = viewModel.playlistArtworkName {
                        CachedAsyncImage(url: url)
                            .frame(width: 300, height: 300)
                            .cornerRadius(8)
                            .shadow(color: .secondary, radius: 8)
                            .padding()
                    } else {
                        AsyncButton(
                            title: "Generate Dalle Image",
                            icon: "photo",
                            action: {
                                let (id, artwork) = await viewModel.generateDalleImage()
                                guard let list = playlists.first(where: { $0.playlistID == id }) else {
                                    return
                                }
                                list.artworkFileName = artwork
                            },
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
            if !viewModel.playlistSuggestion.isEmpty && spotifyService.isAuthorized {
                AsyncButton(
                    title: "Add to Spotify",
                    icon: "music.note.list",
                    action: {},//viewModel.createAndAddPlaylistToSpotify,
                    isLoading: .constant(false),//$viewModel.isAddingToSpotify,
                    colors: [.green, .darkGreen],
                    progress: $viewModel.progress
                )
            } else if !viewModel.playlistSuggestion.isEmpty && !spotifyService.isAuthorized {
                Link(destination: spotifyService.authorizationURL, label: {
                    Text("Connect Spotify")
                        .modifier(AsyncButtonModifier(colors: [.green, .darkGreen]))
                })
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
    
    func fetchPlaylistSuggestion() async {
        let (title, tracks) = await {
            return viewModel.selectedVisionImageData == nil
            ? await viewModel.fetchPlaylistSuggestion()
            : await viewModel.fetchPlaylistSuggestionBasedOnImage()
        }()
        
        await MainActor.run {
            viewModel.playlistSuggestion = tracks
            let playlist = DBPlaylist(title: title, tracks: tracks)
            modelContext.insert(playlist)
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
