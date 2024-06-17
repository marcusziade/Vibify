import Foundation

extension Array<DBTrack> {
    
    var dallePrompt: String {
        let songNames = self
            .map { "\($0.title)" }
            .joined(separator: "\n")
        
        let genreNames = self
            .map { $0.genreNames }
            .reduce(into: Set<String>()) { $0.formUnion($1) }
            .prefix(3)
            .joined(separator: ", ")
        
        return
"""
Create a cover image for a music playlist that takes inspiration from these song names and genres. It should convey the emotion in a way that is visually interesting without writing text. Only create abstract visual imagery. Include some of the song names and all the three genre names.

Song names:
\(songNames)

Genres:
\(genreNames)
"""
    }
}
