import Foundation
import SwiftUI

struct AsyncButton: View {
    let title: String
    let icon: String
    let action: () async -> Void
    @Binding var isLoading: Bool
    let colors: [Color]
    @Binding var progress: Double
    var showLoadingBar: Bool = true
    
    var body: some View {
        Button {
            Task {
                isLoading = true
                await action()
                isLoading = false
            }
        } label: {
            if isLoading {
                CustomProgressView(
                    progress: $progress,
                    title: title,
                    showLoadingBar: showLoadingBar
                )
            } else {
                Label(title, systemImage: icon)
            }
        }
        .buttonStyle(AsyncButtonStyle(colors: colors))
        .disabled(isLoading)
    }
}

struct AsyncButtonStyle: ButtonStyle {
    let colors: [Color]
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(LinearGradient(colors: colors, startPoint: .bottom, endPoint: .top))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal)
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
            title: "Add to Spotify",
            icon: "music.note",
            action: { },
            isLoading: .constant(false),
            colors: [.green, .darkGreen],
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
            title: "Add to Spotify",
            icon: "music.note",
            action: { },
            isLoading: .constant(true),
            colors: [.green, .darkGreen],
            progress: .constant(0.7)
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
        AsyncButton(
            title: "Share",
            icon: "person",
            action: { },
            isLoading: .constant(true),
            colors: [.orange, .red],
            progress: .constant(0.3),
            showLoadingBar: false
        )
    }
}
