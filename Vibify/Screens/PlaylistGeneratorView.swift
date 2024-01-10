import SwiftUI

struct PlaylistGeneratorView: View {
    @Bindable var viewModel = PlaylistGeneratorVM()
    
    // Grid layout definition
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
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
                        viewModel.showHistory.toggle()
                    } label: {
                        Image(systemName: "clock")
                    }
                }
            }
            .alert(isPresented: $viewModel.showingAlert, content: alert)
            .sheet(isPresented: $viewModel.showHistory) {
                PlaylistHistoryView(viewModel: PlaylistHistoryViewModel(dbManager: viewModel.databaseManager))
            }
        }
    }
}

// MARK: - Subviews and Components
private extension PlaylistGeneratorView {
    // Main content view
    var mainContentView: some View {
        ScrollView {
            VStack(spacing: .zero) {
                decadeSlider
                numberOfSongsSlider
                genreGrid
                MoodSelectorView(selectedMood: $viewModel.searchCriteria.mood)
                ActivityPickerView(selectedActivity: $viewModel.searchCriteria.activity)
                favoriteArtistsTextField
                surpriseMeButton
                specificPreferencesTextField
                getSuggestionButton
                songCardListView
                addToAppleMusicButton
                sharePlaylistButton
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
    
    var genrePicker: some View {
        VStack {
            Text("Genre").font(.headline)
            Picker("Genre", selection: $viewModel.selectedGenre) {
                ForEach(viewModel.genreList, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding(.horizontal)
    }
    
    var decadeSlider: some View {
        VStack {
            Text("Decade: \(String(format: "%.0f", viewModel.searchCriteria.decade))").font(.headline)
            Slider(value: $viewModel.searchCriteria.decade, in: viewModel.decadeRange, step: 10)
        }
        .padding(.horizontal)
    }
    
    var numberOfSongsSlider: some View {
        VStack {
            Text("Number of Songs: \(Int(viewModel.searchCriteria.numberOfSongs))").font(.headline)
            Slider(value: $viewModel.searchCriteria.numberOfSongs, in: 0...25, step: 1)
        }
        .padding(.horizontal)
    }
    
    // Genre Grid
    var genreGrid: some View {
        LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
            ForEach(viewModel.genreList, id: \.self) { genre in
                GenreButton(genre: genre, selectedGenres: $viewModel.selectedGenres)
            }
        }
    }
    
    // Favorite Artists TextField
    var favoriteArtistsTextField: some View {
        TextField(
            "Favorite Artists",
            text: $viewModel.searchCriteria.favoriteArtist
        )
        .padding(.top, 8)
    }
    
    // Surprise Me Button
    var surpriseMeButton: some View {
        Button("Surprise Me") {
            Task { viewModel.generateRandomPlaylist }
        }
        .padding(.top, 8)
    }
    
    // Specific Preferences TextField
    var specificPreferencesTextField: some View {
        TextField("Specific Preferences", text: $viewModel.searchCriteria.specificPreferences)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal)
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
