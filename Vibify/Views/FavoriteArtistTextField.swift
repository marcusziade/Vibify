import Foundation
import SwiftUI

// FavoriteArtistTextField for inputting a favorite artist
struct FavoriteArtistTextField: View {
    @Binding var favoriteArtist: String
    
    var body: some View {
        TextField("Favorite Artist", text: $favoriteArtist)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
    }
}
