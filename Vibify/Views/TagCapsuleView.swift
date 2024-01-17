import Foundation
import SwiftUI

struct TagCapsuleView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var tag: String
    var isSelected: Bool
    var isInTagsList = false
    var isDeselectable = false
    var showPencilIcon = false
    var selectedColorGradient: (Color, Color) = (.blue, .purple)
    var onTap: (() -> Void)?
    
    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: 4) {
                Text(tag)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(textColor)
                iconView
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(backgroundLinearGradientView)
            .clipShape(Capsule())
            .shadow(radius: 2)
        }
    }
    
    private var textColor: Color {
        if colorScheme == .dark && isSelected {
            return .white
        } else if colorScheme == .dark && !isSelected {
            return .white
        } else if colorScheme != .dark && isSelected {
            return .white
        } else {
            return .blue
        }
    }
    
    private var iconView: some View {
        let iconSize: CGFloat = 16
        
        return Group {
            if showPencilIcon {
                Image(systemName: "pencil")
                    .resizable()
                    .frame(width: iconSize, height: iconSize)
            } else if isDeselectable && isSelected {
                Image(systemName: "xmark")
                    .resizable()
                    .frame(width: iconSize, height: iconSize)
            }
        }
        .foregroundColor(.blue)
    }
    
    private var backgroundLinearGradientView: some View {
        let unSelectedColors: [Color] = colorScheme == .dark ? [.gray] : [.white]
        return LinearGradient(
            gradient: Gradient(colors: isSelected ? [selectedColorGradient.0, selectedColorGradient.1] : unSelectedColors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

#Preview {
    var randomGradientColors: (Color, Color) {
        let colors: [Color] = [.blue, .green, .red, .orange, .pink, .purple, .yellow]
        return (colors.randomElement()!, colors.randomElement()!)
    }
    
    return VStack {
        ForEach(0..<5) { n in
            TagCapsuleView(
                tag: "Tag \(n + 1)",
                isSelected: Bool.random(),
                selectedColorGradient: randomGradientColors,
                onTap: {}
            )
            .padding(.vertical, 4)
        }
    }
}
