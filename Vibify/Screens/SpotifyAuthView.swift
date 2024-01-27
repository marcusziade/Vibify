import Foundation
import SwiftUI

struct SpotifyAuthView: View {
    
    @Environment(SpotifyService.self) var spotifyService
    @Environment(\.presentationMode) var presentationMode
    
    @State private var authURL: URL?
    @State private var isPresentingSafariView = false
    
    var body: some View {
        VStack {
            if let authURL = authURL {
                Button("Log in to Spotify") {
                    isPresentingSafariView = true
                }
                .sheet(isPresented: $isPresentingSafariView) {
                    SafariView(url: authURL)
                }
            } else {
                Text("Loading...")
            }
        }
        .onAppear {
            spotifyService.authorize { url in
                self.authURL = url
            }
        }
    }
}

#Preview {
    SpotifyAuthView()
}
