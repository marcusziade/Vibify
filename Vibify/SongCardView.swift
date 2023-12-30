import SwiftUI

struct SongCardView: View {
    let song: SongMetadata
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                AsyncImage(url: song.artworkURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image.resizable()
                    case .failure:
                        Image(systemName: "music.note")
                    @unknown default:
                        EmptyView()
                    }
                }
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
    SongCardView(song: SongMetadata(
        title: "Song Title",
        artist: "Song Artist",
        album: "Song Album",
        artworkURL: URL(string: "https://example.com/artwork.jpg"),
        releaseDate: Date(),
        genreNames: ["Pop", "Dance"],
        isExplicit: false,
        appleMusicID: "1234567890"
    ))
}
