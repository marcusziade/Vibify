import Foundation
import SwiftUI

struct PlaylistHistoryView: View {
    
    @Bindable var viewModel: PlaylistHistoryViewModel
    
    var body: some View {
        List(viewModel.playlistHistory) { playlist in
            VStack(alignment: .leading) {
                Text(playlist.title)
                Text(playlist.playlistID)
                Text(playlist.createdAt.formatted())
                Text(String(playlist.duration.formatted()))
                
                LazyVGrid(columns: columns) {
                    ForEach(playlist.songArtworkURLs, id: \.self) { url in
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .clipped()
                        } placeholder: {
                            ProgressView()
                        }
                    }
                }
            }
        }
        .listStyle(.grouped)
    }
    
    private var columns: [GridItem] {
        [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
    }
}
