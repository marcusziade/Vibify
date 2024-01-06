import Foundation
import SwiftUI

struct PlaylistHistoryView: View {
    
    @Bindable var viewModel: PlaylistHistoryViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.playlistHistory) { playlist in
                VStack(alignment: .leading, spacing: 8) {
                    Text(playlist.title)
                        .font(.headline)
                        .accessibilityLabel(Text("Playlist title: \(playlist.title)"))
                    
                    Text("Created at \(playlist.createdAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .accessibilityLabel(Text("Created on \(playlist.createdAt.formatted(date: .abbreviated, time: .shortened))"))
                    
                    Text("Total Playtime: \(playlist.duration.formattedPlaytime())")
                        .font(.footnote)
                        .accessibilityLabel(Text("Total playtime: \(playlist.duration.formattedPlaytime())"))
                    
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(playlist.songArtworkURLs.enumerated().map({ UniqueURL(id: $0.offset, url: $0.element) }), id: \.id) { uniqueURL in
                            AsyncImage(url: uniqueURL.url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .clipped()
                            } placeholder: {
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .accessibilityLabel(Text("Loading artwork"))
                            }
                            .frame(width: 60, height: 60)
                            .accessibilityLabel(Text("Album artwork"))
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.systemGroupedBackground))
                .cornerRadius(8)
            }
            .listStyle(.grouped)
            .navigationTitle("Playlist History")
        }
    }
    
    private var columns: [GridItem] {
        Array(repeating: .init(.flexible()), count: 5)
    }
}

#Preview {
    PlaylistHistoryView(viewModel: PlaylistHistoryViewModel())
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
