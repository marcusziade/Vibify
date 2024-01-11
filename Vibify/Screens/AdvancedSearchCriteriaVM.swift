import Foundation
import Combine
import Observation

@Observable final class AdvancedSearchCriteriaVM {
    var decade: Double = 1980
    var numberOfSongs: Double = 10
    var selectedGenres: Set<String> = []
    var mood: String = ""
    var activity: String = ""
    var favoriteArtist: String = ""
    var specificPreferences: String = ""
    var searchCriteria = SongSearchCriteria()
    
    let genreList = [
        "Rock",
        "Pop",
        "Jazz",
        "Classical",
        "Hip-Hop",
        "Electronic",
        "Blues",
        "Country",
        "Folk",
        "R&B",
        "Reggae",
        "Metal",
        "Punk",
        "Soul",
        "Funk",
        "Latin",
        "Gospel",
        "World",
        "Dance",
        "Indie",
        "Alternative",
        "House",
        "Techno",
        "Trance",
        "Opera",
        "Ska",
        "Grime",
        "D&B",
        "Dubstep",
        "Ambient",
        "New Age",
        "Reggaeton",
        "K-Pop",
        "J-Pop",
        "C-Pop"
    ]

    init(from existingCriteria: SongSearchCriteria? = nil) {
        if let criteria = existingCriteria {
            self.decade = criteria.decade
            self.numberOfSongs = criteria.numberOfSongs
            self.selectedGenres = criteria.selectedGenres
            self.mood = criteria.mood
            self.activity = criteria.activity
            self.favoriteArtist = criteria.favoriteArtist
            self.specificPreferences = criteria.specificPreferences
        }
    }
    
    func updateMainViewModel(_ mainViewModel: PlaylistGeneratorVM) {
        mainViewModel.searchCriteria.decade = decade
        mainViewModel.searchCriteria.numberOfSongs = numberOfSongs
        mainViewModel.searchCriteria.selectedGenres = selectedGenres
        mainViewModel.searchCriteria.mood = mood
        mainViewModel.searchCriteria.activity = activity
        mainViewModel.searchCriteria.favoriteArtist = favoriteArtist
        mainViewModel.searchCriteria.specificPreferences = specificPreferences
    }
}
