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
                        ForEach(playlist.songArtworkURLs, id: \.self) { url in
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .clipped()
                            } placeholder: {
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.gray)
                                    .frame(width: 50, height: 50)
                                    .accessibilityLabel(Text("Loading artwork"))
                            }
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
