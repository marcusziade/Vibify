import Foundation

extension CharacterSet {
    
    /// The character set for percent encoding.
    static let urlQueryValueAllowed: CharacterSet = {
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove("+")
        allowed.remove(charactersIn: "&=")
        return allowed
    }()
}
