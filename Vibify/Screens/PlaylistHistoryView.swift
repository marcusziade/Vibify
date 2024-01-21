import CachedAsyncImage
import Foundation
import SwiftUI

struct PlaylistHistoryView: View {
    
    @Bindable var viewModel: PlaylistHistoryViewModel
    
    var body: some View {
        NavigationView {
            playlistListView
                .listStyle(.grouped)
                .navigationTitle("Playlist History")
        }
    }
}

private extension PlaylistHistoryView {
    
    var playlistListView: some View {
        List(viewModel.playlistHistory) { playlist in
            VStack(alignment: .leading, spacing: 8) {
                playlistTitle(for: playlist)
                creationDate(for: playlist)
                totalPlaytime(for: playlist)
                artworkGrid(for: playlist)
                coverImage(for: playlist)
            }
        }
    }
    
    func playlistTitle(for playlist: DBPlaylist) -> some View {
        Text(playlist.topTwoGenres.joined(separator: ", "))
            .font(.headline)
            .accessibilityLabel(Text("Playlist title: \(playlist.title)"))
    }
    
    func creationDate(for playlist: DBPlaylist) -> some View {
        Text("Created at \(playlist.createdAt.formatted(date: .abbreviated, time: .shortened))")
            .font(.subheadline)
            .foregroundColor(.secondary)
            .accessibilityLabel(Text("Created on \(playlist.createdAt.formatted(date: .abbreviated, time: .shortened))"))
    }
    
    func totalPlaytime(for playlist: DBPlaylist) -> some View {
        Text("Total Playtime: \(playlist.duration.formattedPlaytime())")
            .font(.footnote)
            .accessibilityLabel(Text("Total playtime: \(playlist.duration.formattedPlaytime())"))
    }
    
    func artworkGrid(for playlist: DBPlaylist) -> some View {
        LazyVGrid(columns: columns, spacing: .zero) {
            ForEach(playlist.songArtworkURLs.enumerated().map({ UniqueURL(id: $0.offset, url: $0.element) }), id: \.id) { uniqueURL in
                artworkImage(for: uniqueURL.url)
            }
        }
    }
    
    func artworkImage(for url: URL) -> some View {
        CachedAsyncImage(url: url)
            .aspectRatio(1, contentMode: .fill)
            .clipped()
            .accessibilityLabel(Text("Album artwork"))
    }
    
    func coverImage(for playlist: DBPlaylist) -> some View {
        Group {
            if
                let urlString = playlist.artworkURL,
                let url = URL(string: urlString)
            {
                CachedAsyncImage(url: url)
                    .frame(height: 200)
                    .scaledToFit()
            }
        }
    }
    
    var columns: [GridItem] {
        Array(repeating: .init(.flexible()), count: 5)
    }
}

#Preview {
    PlaylistHistoryView(viewModel: PlaylistHistoryViewModel(dbManager: DatabaseManager()))
}

/// `UniqueURL` is a struct used to provide unique identifiers for items within a SwiftUI `ForEach` loop.
///
/// In SwiftUI, each item in a `ForEach` loop needs a unique identifier for efficient view management.
/// This struct is particularly useful when iterating over a collection that might contain duplicate items,
/// such as URLs. By pairing each URL with its index, `UniqueURL` ensures that each item is uniquely identifiable,
/// even if the URLs themselves are not unique.
///
/// Properties:
/// - `id`: An integer serving as the unique identifier. Typically, this is the index of the URL in the original array.
/// - `url`: The `URL` object being represented.
///
/// Usage:
/// In the `ForEach` loop, use `UniqueURL` instances created from an array of URLs to ensure each item is unique.
/// Example:
/// ```
/// ForEach(playlist.songArtworkURLs.enumerated().map({ UniqueURL(id: $0.offset, url: $0.element) }), id: \.id) { uniqueURL in
///     // Your view code here
/// }
/// ```
struct UniqueURL {
    let id: Int
    let url: URL
}
