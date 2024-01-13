import Foundation
import SwiftUI

struct AsyncButton: View {
    
    let title: String
    let icon: String
    let action: () async -> Void
    @Binding var isLoading: Bool
    let colors: [Color]
    
    var body: some View {
        Button {
            Task {
                isLoading = true
                await action()
                isLoading = false
            }
        } label: {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                    .padding()
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
            colors: [.purple, .pink]
        )
        AsyncButton(
            title: "Share",
            icon: "person",
            action: { },
            isLoading: .constant(false),
            colors: [.orange, .red]
        )
        AsyncButton(
            title: "Surprise Me",
            icon: "person",
            action: { },
            isLoading: .constant(false),
            colors: [.blue, .green]
        )
        
        AsyncButton(
            title: "Add to Apple Music",
            icon: "person",
            action: { },
            isLoading: .constant(true),
            colors: [.purple, .pink]
        )
        AsyncButton(
            title: "Share",
            icon: "person",
            action: { },
            isLoading: .constant(true),
            colors: [.orange, .red]
        )
        AsyncButton(
            title: "Surprise Me",
            icon: "person",
            action: { },
            isLoading: .constant(true),
            colors: [.blue, .green]
        )
    }
}
