import Foundation

extension Data {
    
    func toBase64() -> String {
        self.base64EncodedString()
    }
}
