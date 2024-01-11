import Foundation
import SwiftUI

struct SurpriseMeButton: View {
    var action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "shuffle")
                Text("Surprise Me!")
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(LinearGradient(gradient: Gradient(colors: [.orange, .red]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(10)
            .shadow(radius: 5)
        }
        .padding()
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut) {
                isPressed = pressing
            }
        }, perform: {})
    }
}
