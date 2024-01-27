import Foundation
import SwiftUI
import SafariServices

/// Custom SFSafariViewController SwiftUI wrapper.
struct SafariView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = SFSafariViewController
    
    let url: URL
    
    func makeUIViewController(
        context: Context
    ) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }
    
    func updateUIViewController(
        _ uiViewController: SFSafariViewController,
        context: Context
    ) {
        // No-op
    }
}
