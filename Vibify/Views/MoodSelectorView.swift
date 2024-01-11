import Foundation
import SwiftUI

struct MoodSelectorView: View {
    @Binding var selectedMood: String
    let moods = ["Chill", "Energetic", "Melancholic"]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(moods, id: \.self) { mood in
                    MoodButton(mood: mood, isSelected: selectedMood == mood) {
                        withAnimation {
                            selectedMood = mood
                        }
                    }
                    .padding(3)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct MoodButton: View {
    let mood: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(mood)
                .foregroundColor(isSelected ? .white : .black)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(isSelected ? .blue : .white)
                .clipShape(Capsule())
                .shadow(radius: 2)
        }
    }
}

#Preview {
    MoodSelectorView(selectedMood: .constant(""))
}
