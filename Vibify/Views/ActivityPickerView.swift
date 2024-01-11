import Foundation
import SwiftUI

struct ActivityPickerView: View {
    @Binding var selectedActivity: String
    let activities = ["Workout", "Study", "Party"]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(activities, id: \.self) { activity in
                    ActivityButton(activity: activity, isSelected: selectedActivity == activity) {
                        withAnimation {
                            selectedActivity = activity
                        }
                    }
                    .padding(3)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct ActivityButton: View {
    let activity: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(activity)
                .foregroundColor(isSelected ? .white : .black)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(isSelected ? .green : .white)
                .clipShape(Capsule())
                .shadow(radius: 2)
        }
    }
}
