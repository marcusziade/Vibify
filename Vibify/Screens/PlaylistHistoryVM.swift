import Foundation
import Observation
import os.log
import SwiftData
import SwiftUI

@Observable
final class PlaylistHistoryViewModel {
    
    var importProgress: Double = 0.0
    var importingState: [String: Bool] = [:]
    private let appleMusicImporter: AppleMusicImporter
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "PlaylistHistoryViewModel")
    
    init(appleMusicImporter: AppleMusicImporter) {
        self.appleMusicImporter = appleMusicImporter
    }
    
    func importPlaylistToAppleMusic(playlist: DBPlaylist) async {
        logger.info("Starting to import playlist to Apple Music: \(playlist.title)")
        importingState[playlist.id.entityName] = true
        importProgress = 0.0
        
        guard await appleMusicImporter.requestAppleMusicAccess() else {
            logger.error("User not authorized for Apple Music")
            return
        }
        
        guard let songs = playlist.tracks else {
            logger.error("No songs in playlist")
            return
        }
        
        do {
            let createdPlaylist = try await appleMusicImporter.createPlaylist(named: playlist.title)
            let result = await appleMusicImporter.addTracksToPlaylist(
                playlist: createdPlaylist,
                tracks: songs,
                progressHandler: { [unowned self] newProgress in
                    importProgress = newProgress
                }
            )
            switch result {
            case .success():
                logger.info("Playlist \(playlist.title) imported to Apple Music successfully.")
            case .failure(let error):
                logger.error("Failed to import playlist to Apple Music: \(error.localizedDescription)")
            }
        } catch {
            logger.error("Failed to import playlist: \(error.localizedDescription)")
        }
        
        importingState[playlist.id.entityName] = false
        importProgress = 0.0
    }
}
