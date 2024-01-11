import Foundation
import SwiftUI

struct FavoriteArtistTextField: View {
    @Binding var favoriteArtist: String
    
    var body: some View {
        HStack {
            Image(systemName: "music.mic")
                .foregroundColor(.gray)
            TextField("Favorite Artists", text: $favoriteArtist)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}
