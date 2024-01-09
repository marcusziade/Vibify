import Foundation
import SwiftUI

// SharePlaylistButton for sharing the playlist
struct SharePlaylistButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("Share Playlist")
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.purple)
            .cornerRadius(10)
        }
        .padding()
    }
}
