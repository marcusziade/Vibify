import Foundation
import SwiftUI

struct VisionGeneratorView: View {
    @State private var selectedImageData: Data?
    @State private var isPickerPresented = false
    @State private var playlistSuggestion: String = ""
    
    var body: some View {
        ScrollView {
            VStack {
                Button("Pick Image") {
                    isPickerPresented = true
                }
                
                if !playlistSuggestion.isEmpty {
                    Text(playlistSuggestion)
                        .padding()
                        .multilineTextAlignment(.leading)
                }
                
                if
                    let imageData = selectedImageData,
                    let uiImage = UIImage(data: imageData)
                {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                }
                
                AsyncButton(
                    title: "Generate playlist",
                    icon: "cpu",
                    action: {
                        if let imageData = selectedImageData {
                            let base64String = imageData.toBase64()
                            let messages = [
                                VisionRequest.Message(
                                    role: "user",
                                    content: [
                                        VisionRequest.Message.Content(
                                            type: "text",
                                            text: "Use this image and come up with a playlist that fits the image in mood and aura. List the songs out as a numbered list. Don't explain anything. Only the list. I want a playlist with 10 songs.",
                                            imageURL: nil,
                                            base64Image: base64String
                                        )
                                    ]
                                )
                            ]
                            
                            do {
                                playlistSuggestion = try await generator.describeImage(messages: messages)
                            } catch {
                                debugPrint("Error generating suggestion from vision: \(error)")
                            }
                        }
                    },
                    isLoading: .constant(false),
                    colors: [.black, .clear],
                    progress: .constant(.zero)
                )
            }
        }
        .sheet(isPresented: $isPickerPresented) {
            PhotoPicker(selectedImageData: $selectedImageData)
        }
    }
    
    // MARK: Private
    
    private let generator = VisionGenerator(networkService: URLSessionNetworkService())
    
    private var apiKey: String? {
        ProcessInfo.processInfo.environment["API_KEY"]
    }
}

#Preview {
    VisionGeneratorView()
}
