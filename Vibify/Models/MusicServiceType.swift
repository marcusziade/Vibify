import Foundation
import SwiftUI

enum MusicServiceType: String, CaseIterable {
    case appleMusic = "Apple Music"
    case spotify = "Spotify"
    
    var color: Color {
        switch self {
        case .appleMusic:
            return Color.red
        case .spotify:
            return Color.green
        }
    }
}
