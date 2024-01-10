import Foundation
import Combine
import Observation

@Observable final class AdvancedSearchCriteriaVM {
    var decade: Double = 2000
    var numberOfSongs: Double = 10
    var selectedGenres: Set<String> = []
    var mood: String = ""
    var activity: String = ""
    var favoriteArtist: String = ""
    var specificPreferences: String = ""
    var searchCriteria = SongSearchCriteria()
    
    let genreList = ["Rock", "Pop", "Jazz", "Classical", "Hip-Hop", "Electronic"]
    
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
