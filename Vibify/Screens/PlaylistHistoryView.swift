import CachedAsyncImage
import Foundation
import SwiftUI

struct PlaylistHistoryView: View {
    
    @Bindable var viewModel: PlaylistHistoryViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.playlistHistory) { playlist in
                VStack {
                    PlaylistRowView(playlist: playlist)
                    AsyncButton(
                        title: "Add to Apple Music",
                        icon: "music.note.list",
                        action: { await viewModel.importPlaylistToAppleMusic(playlist: playlist) },
                        isLoading: $viewModel.isImportingToAppleMusic,
                        colors: [.purple, .pink],
                        progress: $viewModel.importProgress
                    )
                }
            }
            .listStyle(.grouped)
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
