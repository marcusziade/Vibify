import Foundation

extension URL {
    /// Returns the value of the query item with the specified key.
    func queryItemValue(forKey key: String) -> String? {
        return URLComponents(string: self.absoluteString)?.queryItems?.first(where: { $0.name == key })?.value
    }
}
