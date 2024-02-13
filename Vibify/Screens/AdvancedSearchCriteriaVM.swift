import Foundation
import Combine
import CoreLocation
import MapKit
import Observation

@Observable final class AdvancedSearchCriteriaVM: NSObject {
    var decade: Double = 1980
    var numberOfSongs: Double = 10
    var selectedGenres: Set<String> = []
    var selectedMood: String = ""
    var selectedActivity: String = ""
    var favoriteArtist: String = ""
    var specificPreferences: String = ""
    var searchCriteria = SongSearchCriteria()
    var selectedLocation: CLLocationCoordinate2D?
    var mapRegion: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    var locationManager = CLLocationManager()
    var isLocationAuthorized = false
    
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
        "C-Pop",
        "Gaming",
        "Anime",
        "Soundtrack",
        "Instrumental",
        "A Capella",
        "Comedy",
        "Holiday",
        "JRPG",
        "RPG",
    ]

    init(from existingCriteria: SongSearchCriteria? = nil) {
        super.init()
        locationManager.delegate = self
        
        if let criteria = existingCriteria {
            self.decade = criteria.decade
            self.numberOfSongs = criteria.numberOfSongs
            self.selectedGenres = criteria.selectedGenres
            self.selectedMood = criteria.mood
            self.selectedActivity = criteria.activity
            self.favoriteArtist = criteria.favoriteArtist
            self.specificPreferences = criteria.specificPreferences
        }
    }
    
    func updateMainViewModel(_ mainViewModel: PlaylistGeneratorVM) {
        mainViewModel.searchCriteria.decade = decade
        mainViewModel.searchCriteria.numberOfSongs = numberOfSongs
        mainViewModel.searchCriteria.selectedGenres = selectedGenres
        mainViewModel.searchCriteria.mood = selectedMood
        mainViewModel.searchCriteria.activity = selectedActivity
        mainViewModel.searchCriteria.favoriteArtist = favoriteArtist
        mainViewModel.searchCriteria.specificPreferences = specificPreferences
    }
    
    func selectGenre(_ genre: String) {
        if selectedGenres.contains(genre) {
            selectedGenres.remove(genre)
        } else {
            selectedGenres.insert(genre)
        }
    }
    
    private func updateMapRegion() {
        if let location = selectedLocation {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            mapRegion = MKCoordinateRegion(center: location, span: span)
        }
    }
}

extension AdvancedSearchCriteriaVM: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            isLocationAuthorized = true
            manager.startUpdatingLocation()
        default:
            isLocationAuthorized = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last?.coordinate {
            self.selectedLocation = location
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            mapRegion = MKCoordinateRegion(center: location, span: span)
        }
    }

    func checkLocationAuthorizationStatus() -> CLAuthorizationStatus {
        return locationManager.authorizationStatus
    }
    
    internal func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getCurrentLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func updateSearchCriteriaWithLocation() {
        if let location = locationManager.location?.coordinate {
            searchCriteria.locationCoordinate = location
        }
    }
}
