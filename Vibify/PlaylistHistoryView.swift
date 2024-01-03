import Foundation
import SwiftUI

struct PlaylistHistoryView: View {
    
    @Bindable var viewModel: PlaylistHistoryViewModel
    
    var body: some View {
        List(viewModel.playlistHistory) { playlist in
            VStack(alignment: .leading) {
                Text(playlist.playlistID)
                Text(playlist.createdAt.formatted())
            }
        }
    }
}
