import Foundation
import SwiftUI

struct AsyncButtonModifier: ViewModifier {
    
    let colors: [Color]
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(LinearGradient(colors: colors, startPoint: .bottom, endPoint: .top))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal)
    }
}
