import Foundation
import SwiftUI

/// Custom progress view with circular progress indicator.
struct ImportProgressView: View {
    @Binding var progress: Double
    
    var body: some View {
        VStack {
            Text("Importing...")
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.bottom, 10)
            
            ZStack {
                Circle()
                    .stroke(lineWidth: 10)
                    .opacity(0.3)
                    .foregroundColor(Color.blue)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Color.blue)
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear, value: progress)
                    .frame(width: loaderSize, height: loaderSize)
                
                Text(String(format: "%.0f%%", min(progress, 1.0) * 100.0))
                    .font(.caption)
                    .bold()
            }
        }
        .padding()
    }
    
    private let loaderSize: CGFloat = 80
}

#Preview {
    ImportProgressView(progress: .constant(0.3))
}
