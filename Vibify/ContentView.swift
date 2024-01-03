import SwiftUI

struct ContentView: View {
    @Bindable var viewModel = PlaylistViewModel()
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                ScrollView {
                    VStack(spacing: 20) {
                        genrePicker
                        decadeSlider
                        numberOfSongsSlider
                        specificPreferencesTextField
                        getSuggestionButton
                        songCardListView
                        addToAppleMusicButton
                    }
                    .disabled(viewModel.isLoading)
                }
                .blur(radius: viewModel.isLoading ? 5 : 0)
                .animation(.easeInOut(duration: 0.3), value: viewModel.isLoading)
                
                loaderView
            }
            .toolbar {
                Button {
                    viewModel.showHistory = true
                } label: {
                    Image(systemName: "clock")
                }
            }
            .alert(isPresented: $viewModel.showingAlert, content: alert)
            .sheet(isPresented: $viewModel.showHistory) {
                PlaylistHistoryView(viewModel: PlaylistHistoryViewModel())
            }
        }
    }
}

private extension ContentView {
    
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
            Picker("Genre", selection: $viewModel.searchCriteria.genre) {
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
            Text("Decade: \(selectedDecade)").font(.headline)
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
    
    var specificPreferencesTextField: some View {
        TextField("Specific Preferences", text: $viewModel.searchCriteria.specificPreferences)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal)
    }
    
    @MainActor var getSuggestionButton: some View {
        Button {
            withAnimation { viewModel.fetchPlaylistSuggestion() }
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
    
    var selectedDecade: String {
        "\(Int(viewModel.searchCriteria.decade / 10) * 10)s"
    }
    
    func alert() -> Alert {
        Alert(title: Text("Playlist Generator"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
    }
}

#Preview {
    ContentView(viewModel: PlaylistViewModel())
}
