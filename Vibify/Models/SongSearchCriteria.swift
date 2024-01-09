import Foundation

struct SongSearchCriteria {
    var genreProportions: [String: Double] = [:]
    var mood: String = ""
    var activity: String = ""
    var favoriteArtist: String = ""
    var decade: Double = 1990
    var numberOfSongs: Double = 3
    var specificPreferences: String = ""
    var includeInstrumentals: Bool = false
    var includeVocals: Bool = true
    var bpmRange: ClosedRange<Double> = 60...200
    var languagePreference: String = "English"
    
    func toPrompt() -> String {
        var promptComponents: [String] = []
        
        if !genreProportions.isEmpty {
            let genres = genreProportions.map { "\($0.key): \($0.value)" }
            promptComponents.append("Genres: \(genres.joined(separator: ", "))")
        }
        if !mood.isEmpty {
            promptComponents.append("Mood: \(mood)")
        }
        if !activity.isEmpty {
            promptComponents.append("Activity: \(activity)")
        }
        if !favoriteArtist.isEmpty {
            promptComponents.append("Artist like: \(favoriteArtist)")
        }
        if decade > 0 {
            promptComponents.append("Decade: \(Int(decade))s")
        }
        if numberOfSongs > 0 {
            promptComponents.append("Number of songs: \(Int(numberOfSongs))")
        }
        if !specificPreferences.isEmpty {
            promptComponents.append("Preferences: \(specificPreferences)")
        }
        if includeInstrumentals {
            promptComponents.append("Include: Instrumentals")
        }
        if !includeVocals {
            promptComponents.append("Exclude: Vocals")
        }
        promptComponents.append("BPM range: \(Int(bpmRange.lowerBound))-\(Int(bpmRange.upperBound))")
        if !languagePreference.isEmpty {
            promptComponents.append("Language: \(languagePreference)")
        }
        
        return promptComponents.joined(separator: "\n")
    }
}
