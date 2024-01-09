import Foundation
import SwiftUI

// ActivityPickerView for selecting the activity the playlist is for
struct ActivityPickerView: View {
    @Binding var selectedActivity: String
    let activities = ["Workout", "Study", "Party"]
    
    var body: some View {
        VStack {
            Text("Activity").font(.headline)
            Picker("Activity", selection: $selectedActivity) {
                ForEach(activities, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding()
    }
}
