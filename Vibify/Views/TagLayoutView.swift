import Foundation
import SwiftUI

/// A ``PreferenceKey`` implementation to track and store the maximum height of a view.
private struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

/// View component that displays tags in a horizontally wrapping layout.
@MainActor struct TagLayoutView: View {
    /// The list of tags to display.
    let tags: [String]
    /// Callback that will be triggered when a tag is tapped.
    let onTap: (String) -> Void
    /// List of tags that are currently selected.
    let selectedTags: [String]
    
    /// The calculated total height needed for the tags.
    @State private var totalHeight: CGFloat = 0
    
    var body: some View {
        ScrollView {
            GeometryReader { geometry in
                tagLayout(in: geometry)
            }
            .frame(height: totalHeight)
        }
    }
    
    private func tagLayout(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return ZStack(alignment: .topLeading) {
            ForEach(tags, id: \.self) { tag in
                TagCapsuleView(
                    tag: tag,
                    isSelected: selectedTags.contains { $0 == tag },
                    isInTagsList: true
                ) {
                    onTap(tag)
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 6)
                .alignmentGuide(.leading) { d in
                    calculateAlignment(
                        for: tag,
                        with: geometry,
                        using: d,
                        width: &width,
                        height: &height
                    )
                }
                .alignmentGuide(.top) { _ in
                    let result = height
                    if let lastTag = tags.last, tag == lastTag {
                        height = 0
                    }
                    return result
                }
            }
        }
        .background(GeometryReader { newGeometry in
            Color.clear.preference(
                key: ViewHeightKey.self,
                value: newGeometry.size.height
            )
        })
        .onPreferenceChange(ViewHeightKey.self) { newTotalHeight in
            totalHeight = newTotalHeight
        }
    }
    
    private func calculateAlignment(
        for tag: String,
        with geometry: GeometryProxy,
        using d: ViewDimensions,
        width: inout CGFloat,
        height: inout CGFloat
    ) -> CGFloat {
        guard let lastTag = tags.last else {
            return d[.leading]
        }
        
        if abs(width - d.width) > geometry.size.width {
            width = 0
            height -= d.height
        }
        
        let result = width
        width = tag == lastTag ? .zero : width - d.width
        return result
    }
}

#Preview {
    let twentyTags = (1...20).map { "Tag \($0)" }
    return TagLayoutView(
        tags: twentyTags,
        onTap: {_ in },
        selectedTags: twentyTags.filter { $0.contains("1") }
    )
}
