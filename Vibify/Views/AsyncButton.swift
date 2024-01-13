import Foundation
import SwiftUI

struct AsyncButton: View {
    let title: String
    let icon: String
    let action: () async -> Void
    @Binding var isLoading: Bool
    let colors: [Color]
    @Binding var progress: Double
    
    var body: some View {
        Button {
            Task {
                isLoading = true
                await action()
                isLoading = false
            }
        } label: {
            if isLoading {
                CustomProgressView(progress: Binding.constant(progress), title: title)
                    .frame(maxWidth: .infinity)
                    .background(LinearGradient(colors: colors, startPoint: .bottom, endPoint: .top))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal)
            } else {
                Label(title, systemImage: icon)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(LinearGradient(colors: colors, startPoint: .bottom, endPoint: .top))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal)
            }
        }
        .disabled(isLoading)
    }
}
#Preview {
    VStack {
        AsyncButton(
            title: "Add to Apple Music",
            icon: "person",
            action: { },
            isLoading: .constant(false),
            colors: [.purple, .pink], 
            progress: .constant(.zero)
        )
        AsyncButton(
            title: "Share",
            icon: "person",
            action: { },
            isLoading: .constant(false),
            colors: [.orange, .red], 
            progress: .constant(.zero)
        )
        AsyncButton(
            title: "Surprise Me",
            icon: "person",
            action: { },
            isLoading: .constant(false),
            colors: [.blue, .green], 
            progress: .constant(.zero)
        )
        
        AsyncButton(
            title: "Add to Apple Music",
            icon: "person",
            action: { },
            isLoading: .constant(true),
            colors: [.purple, .pink], 
            progress: .constant(0.5)
        )
        AsyncButton(
            title: "Share",
            icon: "person",
            action: { },
            isLoading: .constant(true),
            colors: [.orange, .red], 
            progress: .constant(0.3)
        )
        AsyncButton(
            title: "Surprise Me",
            icon: "person",
            action: { },
            isLoading: .constant(true),
            colors: [.blue, .green], 
            progress: .constant(0.8)
        )
        AsyncButton(
            title: "Surprise Me",
            icon: "person",
            action: { },
            isLoading: .constant(true),
            colors: [.purple, .pink],
            progress: .constant(1.0)
        )
    }
}
