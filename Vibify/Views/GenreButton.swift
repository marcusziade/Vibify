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
            withAnimation(.easeInOut(duration: 0.2)) {
                if isSelected {
                    selectedGenres.remove(genre)
                } else {
                    selectedGenres.insert(genre)
                }
            }
        }) {
            Text(genre)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(isSelected ? .white : .blue)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(LinearGradient(gradient: Gradient(colors: isSelected ? [.blue, .purple] : [.white]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .clipShape(Capsule())
                .shadow(radius: 5)
        }
    }
    
    private let size: CGFloat = 80
}
