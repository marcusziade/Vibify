import Foundation
import SwiftUI

// SurpriseMeButton for generating a random playlist
struct SurpriseMeButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Surprise Me!")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.orange)
                .cornerRadius(10)
        }
        .padding()
    }
}
