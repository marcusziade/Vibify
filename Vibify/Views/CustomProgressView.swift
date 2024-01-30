import Foundation
import SwiftUI

/// Custom progress view with rectangular progress indicator.
struct CustomProgressView: View {
    @Binding var progress: Double
    let title: String
    let showLoadingBar: Bool
    
    var body: some View {
        VStack {
            HStack(spacing: 4) {
                ProgressView()
                    .tint(.white)
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            if showLoadingBar {
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: loaderSize, height: 20)
                        .opacity(0.3)
                        .foregroundColor(.white)
                    
                    Rectangle()
                        .frame(width: max(CGFloat(progress) * loaderSize, 0), height: 20)
                        .foregroundColor(.green)
                        .animation(.snappy, value: progress)
                    
                    Text(String(format: "%.0f%%", min(progress, 1.0) * 100.0))
                        .font(.caption)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.leading, 4)
                        .frame(width: loaderSize, alignment: .trailing)
                }
            }
        }
    }
    
    private let loaderSize: CGFloat = 300
}

#Preview {
    CustomProgressView(
        progress: .constant(0.3),
        title: "Generating...",
        showLoadingBar: true
    )
}
