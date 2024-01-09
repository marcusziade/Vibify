import Foundation
import SwiftUI

// MoodSelectorView for selecting the mood of the playlist
struct MoodSelectorView: View {
    @Binding var selectedMood: String
    let moods = ["Chill", "Energetic", "Melancholic"]
    
    var body: some View {
        VStack {
            Text("Select Mood").font(.headline)
            Picker("Mood", selection: $selectedMood) {
                ForEach(moods, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding()
    }
}

