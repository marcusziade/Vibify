import CachedAsyncImage
import Foundation
import SwiftUI

struct PlaylistRowView: View {
    var playlist: DBPlaylist
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            playlistTitleView
            creationDateView
            totalPlaytimeView
            artworkGrid
            coverImage
        }
    }
}

#Preview {
    PlaylistRowView(playlist: DBPlaylist.mock)
}

private extension PlaylistRowView {
    
    var playlistTitleView: some View {
        Text(playlist.topTwoGenres.joined(separator: ", "))
            .font(.headline)
            .accessibilityLabel(Text("Playlist title: \(playlist.title)"))
    }
    
    var creationDateView: some View {
        Text("Created at \(playlist.createdAt.formatted(date: .abbreviated, time: .shortened))")
            .font(.subheadline)
            .foregroundColor(.secondary)
            .accessibilityLabel(Text("Created on \(playlist.createdAt.formatted(date: .abbreviated, time: .shortened))"))
    }
    
    var totalPlaytimeView: some View {
        Text("Total Playtime: \(playlist.duration.formattedPlaytime())")
            .font(.footnote)
            .accessibilityLabel(Text("Total playtime: \(playlist.duration.formattedPlaytime())"))
    }
    
    var artworkGrid: some View {
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
    
    var coverImage: some View {
        Group {
            if let urlString = playlist.artworkURL, let url = URL(string: urlString) {
                CachedAsyncImage(url: url)
                    .frame(width: 150, height: 150)
                    .scaledToFit()
            }
        }
    }
    
    var columns: [GridItem] {
        Array(repeating: .init(.flexible()), count: 5)
    }
}
