import Foundation

/// `UniqueURL` is a struct used to provide unique identifiers for items within a SwiftUI `ForEach` loop.
///#imageLiteral(resourceName: "simulator_screenshot_260EBEBA-D9BB-4443-9338-FEEC9BA26D33.png")
/// In SwiftUI, each item in a `ForEach` loop needs a unique identifier for efficient view management.
/// This struct is particularly useful when iterating over a collection that might contain duplicate items,
/// such as URLs. By pairing each URL with its index, `UniqueURL` ensures that each item is uniquely identifiable,
/// even if the URLs themselves are not unique.
///
/// Properties:
/// - `id`: An integer serving as the unique identifier. Typically, this is the index of the URL in the original array.
/// - `url`: The `URL` object being represented.
///
/// Usage:
/// In the `ForEach` loop, use `UniqueURL` instances created from an array of URLs to ensure each item is unique.
/// Example:
/// ```
/// ForEach(playlist.songArtworkURLs.enumerated().map({ UniqueURL(id: $0.offset, url: $0.element) }), id: \.id) { uniqueURL in
///     // Your view code here
/// }
/// ```
struct UniqueURL {
    let id: Int
    let url: URL
}
