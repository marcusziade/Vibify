import Foundation
import SwiftUI

struct GenreButton: View {
    var genre: String
    @Binding var selectedGenres: Set<String>
    
    var isSelected: Bool {
        selectedGenres.contains(genre)
    }
    
    var body: some View {
        Button(action: {
            if isSelected {
                selectedGenres.remove(genre)
            } else {
                selectedGenres.insert(genre)
            }
        }) {
            Text(genre)
                .foregroundColor(isSelected ? .white : .blue)
                .frame(width: 100, height: 100)
                .background(isSelected ? Color.blue : Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 2)
                )
        }
        .padding(4)
    }
}
