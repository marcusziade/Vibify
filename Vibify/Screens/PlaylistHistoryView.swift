import CachedAsyncImage
import Foundation
import SwiftUI

struct PlaylistHistoryView: View {
    
    @Bindable var viewModel: PlaylistHistoryViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.playlistHistory) { playlist in
                ZStack {
                    if
                        let urlString = playlist.artworkURL,
                        let url = URL(string: urlString)
                    {
                        CachedAsyncImage(url: url)
                            .scaledToFit()
                            .ignoresSafeArea()
                            .clipped()
                    }
                    VStack {
                        PlaylistRowView(playlist: playlist)
                            .foregroundStyle(.white)
                        AsyncButton(
                            title: "Add to Apple Music",
                            icon: "music.note.list",
                            action: { await viewModel.importPlaylistToAppleMusic(playlist: playlist) },
                            isLoading: Binding(
                                get: { viewModel.importingState[playlist.id] ?? false },
                                set: { _ in }
                            ),
                            colors: [.purple, .pink],
                            progress: $viewModel.importProgress
                        )
                        .disabled(viewModel.importProgress > .zero)
                    }
                }
                .listRowInsets(EdgeInsets(top: 4, leading: .zero, bottom: 4, trailing: .zero))
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .navigationTitle("Playlist History")
        }
    }
}

#Preview {
    PlaylistHistoryView(
        viewModel: PlaylistHistoryViewModel(
            dbManager: Mock_DatabaseManager(),
            appleMusicImporter: AppleMusicImporter()
        )
    )
}
