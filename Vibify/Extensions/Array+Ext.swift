import Foundation

extension Array where Element == DBSongMetadata {
    
    var dallePrompt: String {
        let promptPrefix = "NO TEXT. Create one singular image that takes inspiration from these songs. It will be used as a playlist cover and should convey the emotion of the songs included. No text:"
        
        let songDescriptions = self
            .map { song in
                "\(song.title) by \(song.artist) in \(song.genreNames.joined(separator: ", "))"
            }
            .joined(separator: "; ")
        
        return "\(promptPrefix) \(songDescriptions)"
    }
}
