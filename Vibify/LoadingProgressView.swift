import Foundation
import SwiftUI

struct LoadingProgressView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: loaderSize, height: loaderSize)
                    .rotationEffect(Angle(degrees: self.isAnimating ? 360 : 0))
                    .animation(
                        Animation
                            .linear(duration: 1)
                            .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
                    .onAppear() {
                        isAnimating = true
                    }
                    .onDisappear() {
                        isAnimating = false
                    }
                
                Text("Loading...")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.top, 20)
            }
        }
    }
    
    private let loaderSize: CGFloat = 80
}

#Preview {
    LoadingProgressView()
}
