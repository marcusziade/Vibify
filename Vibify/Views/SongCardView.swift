import AVFoundation
import CachedAsyncImage
import SwiftUI

struct SongCardView: View {
    let song: DBSongMetadata
    let musicService: MusicServiceType = .appleMusic
    var togglePlayback: (DBSongMetadata) -> Void
    var isPlaying: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                CachedAsyncImage(url: song.artworkURL)
                    .frame(width: 60, height: 60)
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(8)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(8)
                
                VStack(alignment: .leading) {
                    Text(song.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Text(song.artist)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    Text(song.album)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Button {
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                    togglePlayback(song)
                } label: {
                    Image(systemName: isPlaying ? "pause.circle" : "play.circle")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(musicService.color)
                }
            }
            
            if let releaseDate = song.releaseDate {
                Text("Released: \(releaseDate, format: .dateTime.year().month().day())")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if !song.genreNames.isEmpty {
                Text("Genres: \(song.genreNames.joined(separator: ", "))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

#Preview {
    SongCardView(song: DBSongMetadata(
        id: UUID().uuidString,
        title: "Song Title",
        artist: "Song Artist",
        album: "Song Album",
        artworkURL: URL(string: "https://example.com/artwork.jpg"),
        releaseDate: Date(),
        genreNames: ["Pop", "Dance"],
        isExplicit: false,
        appleMusicID: "1234567890",
        previewURL: nil
    ), togglePlayback: {_ in }, isPlaying: false)
}
