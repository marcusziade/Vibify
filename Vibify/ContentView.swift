import SwiftUI

struct ContentView: View {
    @Bindable var viewModel = PlaylistViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    genrePicker
                    decadeSlider
                    numberOfSongsSlider
                    specificPreferencesTextField
                    getSuggestionButton
                    loadingView
                    songCardListView
                    addToAppleMusicButton
                }
            }
            .navigationBarTitle("Playlist Generator", displayMode: .inline)
            .alert(isPresented: $viewModel.showingAlert, content: alert)
        }
    }
}

private extension ContentView {
    
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
        .disabled(viewModel.isImporting)
        .padding(.horizontal)
    }
    
    var loadingView: some View {
        Group {
            if viewModel.isImporting {
                ImportProgressView(progress: $viewModel.progress)
            } else if viewModel.isLoading {
                LoadingProgressView()
            }
        }
    }
    
    var songCardListView: some View {
        Group {
            if !viewModel.isImporting {
                ForEach(viewModel.playlistSuggestion, id: \.title) { song in
                    SongCardView(
                        song: song,
                        togglePlayback: viewModel.togglePlayback,
                        isPlaying: viewModel.isCurrentlyPlaying(song: song)
                    )
                }
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
