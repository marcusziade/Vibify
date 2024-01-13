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
                .background(LinearGradient(colors: [.accentColor], startPoint: .bottom, endPoint: .top))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal)
        }
        .disabled(viewModel.isLoading)
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
                        .background(LinearGradient(colors: [.purple, .pink], startPoint: .bottom, endPoint: .top))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.horizontal)
                }
            }
        }
    }
    
    var sharePlaylistButton: some View {
        Group {
            if !viewModel.playlistSuggestion.isEmpty {
                Button {
                    viewModel.sharePlaylist()
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(colors: [.orange, .red], startPoint: .bottom, endPoint: .top))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.horizontal)
                }
            }
        }
    }
    
    var surpriseMeButton: some View {
        Button {
            withAnimation {
//                viewModel.fetchSurprisePlaylist()
            }
        } label: {
            Label("Surprise Me", systemImage: "shuffle")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(LinearGradient(colors: [.blue, .cyan], startPoint: .bottom, endPoint: .top))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal)
        }
        .disabled(viewModel.isLoading)
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
