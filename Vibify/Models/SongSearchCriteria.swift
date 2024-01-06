import Foundation

struct SongSearchCriteria {
    var genre: String = ""
    var decade: Double = 1990
    var numberOfSongs: Double = 3
    var specificPreferences: String = ""
    
    func toPrompt() -> String {
        var promptComponents: [String] = []
        
        if !genre.isEmpty {
            promptComponents.append("Genre: \(genre)")
        }
        if !decade.isNaN {
            promptComponents.append("Decade: \(decade)")
        }
        if numberOfSongs > 0 {
            promptComponents.append("Number of songs: \(numberOfSongs)")
        }
        if !specificPreferences.isEmpty {
            promptComponents.append("Preferences: \(specificPreferences)")
        }
        
        return promptComponents.joined(separator: "\n")
    }
}
