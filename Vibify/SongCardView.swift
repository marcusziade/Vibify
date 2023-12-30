import SwiftUI

struct SongCardView: View {
    let song: SongMetadata
    
    var body: some View {
        HStack {
            if let artworkURL = song.artworkURL {
                AsyncImage(url: artworkURL) { image in
                    image.image?
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                }
            }
            VStack(alignment: .leading) {
                Text(song.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(song.artist)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(song.album)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

#Preview {
    SongCardView(song: SongMetadata(title: "Song Title", artist: "Song Artist", album: "Song Album", artworkURL: nil))
}
