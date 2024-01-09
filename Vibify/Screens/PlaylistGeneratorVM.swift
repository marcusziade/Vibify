import Foundation
import Combine
import StoreKit
import MediaPlayer
import MusicKit
import Observation

@Observable
final class PlaylistGeneratorVM {
    
    var isPlaying: Bool = false
    var playlistSuggestion: [DBSongMetadata] = []
    var isLoading: Bool = false
    var isImporting: Bool = false
    var showHistory: Bool = false
    var progress: Double = 0.0
    var isAuthorizedForAppleMusic: Bool = false
    var showingAlert: Bool = false
    var alertMessage: String = ""
    var searchCriteria = SongSearchCriteria()
    var selectedTheme: String = "Default"
    
    let genreList = ["Rock", "Pop", "Jazz", "Classical", "Hip-Hop", "Electronic"]
    var selectedGenres: Set<String> = []
    
    let decadeRange: ClosedRange<Double> = 1860...Double(Date().year)
    let pastDecadeRange = (Date().year - 10)...Date().year
    
    // This is your new property for the single selected genre.
    var selectedGenre: String {
        get {
            searchCriteria.genreProportions.max(by: { $0.value < $1.value })?.key ?? ""
        }
        set {
            searchCriteria.genreProportions = [newValue: 1.0]
        }
    }
    
    private var currentlyPlayingSong: DBSongMetadata?
    
    let databaseManager: DatabaseManager
    private let playlistGenerator: PlaylistGenerator
    private let appleMusicImporter: AppleMusicImporter
    private let player: AVPlayer
    
    init(
        databaseManager: DatabaseManager = DatabaseManager(),
        playlistGenerator: PlaylistGenerator = PlaylistGenerator(),
        appleMusicImporter: AppleMusicImporter = AppleMusicImporter(),
        player: AVPlayer = AVPlayer()
    ) {
        self.databaseManager = databaseManager
        self.playlistGenerator = playlistGenerator
        self.appleMusicImporter = appleMusicImporter
        self.player = player
        Task { await requestAppleMusicAuthorization() }
    }
    
    func isCurrentlyPlaying(song: DBSongMetadata) -> Bool {
        return currentlyPlayingSong?.title == song.title && isPlaying
    }
    
    @MainActor func fetchPlaylistSuggestion() {
        guard !isLoading else { return }
        playlistSuggestion = []
        isLoading = true
        progress = .zero
        
        Task { [unowned self] in
            do {
                playlistSuggestion = try await playlistGenerator.fetchPlaylistSuggestion(
                    criteria: searchCriteria
                ) { [unowned self] newProgress in
                    progress = Double(newProgress) / 100.0
                }
                
                let primaryGenre = searchCriteria.genreProportions.max(by: { $0.value < $1.value })?.key ?? "No Genre"
                let playlist = DBPlaylist(
                    title: primaryGenre,
                    playlistID: UUID().uuidString,
                    createdAt: Date.now,
                    songs: playlistSuggestion
                )
                try databaseManager.insert(playlist: playlist)
            } catch {
                debugPrint(error)
                presentAlert(with: "Failed to generate playlist: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }
    
    @MainActor func requestAppleMusicAuthorization() async {
        isAuthorizedForAppleMusic = await appleMusicImporter.requestAppleMusicAccess()
    }
    
    func createAndAddPlaylistToAppleMusic() {
        Task {
            guard !playlistSuggestion.isEmpty else {
                await presentAlert(with: "No songs to add to the playlist.")
                return
            }
            isLoading = true
            isImporting = true
            progress = 0.0
            
            do {
                let playlistName = "Playlist \(Date.now.formatted(date: .abbreviated, time: .shortened))"
                let playlist = try await appleMusicImporter.createPlaylist(named: playlistName)
                let result = await appleMusicImporter.addSongsToPlaylist(
                    playlist: playlist,
                    songs: playlistSuggestion,
                    progressHandler: { [unowned self] newProgress in
                        progress = newProgress
                    }
                )
                isLoading = false
                switch result {
                case .success():
                    await presentAlert(with: "Songs added to the playlist successfully.")
                case .failure(let error):
                    await presentAlert(with: "Failed to add songs to the playlist: \(error.localizedDescription)")
                }
            } catch {
                isLoading = false
                await presentAlert(with: "Failed to create playlist: \(error.localizedDescription)")
            }
            
            isImporting = false
        }
    }
    
    @MainActor func generateRandomPlaylist() {
        guard !isLoading else { return }
        isLoading = true
        progress = .zero
        
        // Simulate a network request or computation with a delay
        Task { [unowned self] in
            // Delay for demonstration purposes
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            // Generate a random set of songs
            let randomGenres = genreList.shuffled().prefix(3)  // Take 3 random genres
            let randomDecade = Double(Int.random(in: Int(decadeRange.lowerBound)...Int(decadeRange.upperBound)/10)*10)
            let randomNumberOfSongs = Double(Int.random(in: 1...10))  // Random number of songs between 1 and 10
            
            // Generate a random set of songs
            playlistSuggestion = (1...Int(randomNumberOfSongs)).map { _ in
                DBSongMetadata(
                    id: UUID().uuidString, // 'id' as a unique UUID string
                    title: "Random Song \(Int.random(in: 1...10000))",
                    artist: "Random Artist \(Int.random(in: 1...10000))",
                    album: "Random Album \(Int.random(in: 1...1000))",
                    artworkURL: nil, // You would replace this with an actual URL if available
                    releaseDate: Date.random(in: pastDecadeRange), // You would replace this with an actual date if available
                    genreNames: [randomGenres.randomElement() ?? "No Genre"],
                    isExplicit: Bool.random(),
                    appleMusicID: "\(Int.random(in: 1...10000))",
                    previewURL: nil, // Replace with actual URL if available
                    playlistID: UUID().uuidString, // 'playlistID' as a unique UUID string if needed
                    duration: TimeInterval.random(in: 60...300) // Duration in seconds, as an example
                )
            }

            // You would normally have a function here that fetches actual data based on the criteria
            // For demonstration, we're using mock data
            
            // Update UI after fetching
            isLoading = false
        }
    }
    
    func sharePlaylist() {
        
    }
    
    func togglePlayback(for song: DBSongMetadata) {
        if isCurrentlyPlaying(song: song) {
            player.pause()
            isPlaying = false
        } else {
            playSong(song)
        }
    }
    
    @MainActor private func presentAlert(with message: String) {
        alertMessage = message
        showingAlert = true
    }
    
    private func playSong(_ song: DBSongMetadata) {
        guard let url = song.previewURL else { return }
        if player.rate != 0 {
            player.pause()
        }
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        player.play()
        currentlyPlayingSong = song
        isPlaying = true
    }
}
