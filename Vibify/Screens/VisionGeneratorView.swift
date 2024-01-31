import Foundation
import SwiftUI

struct VisionGeneratorView: View {
    @State private var selectedImageData: Data?
    @State private var isPickerPresented = false
    @State private var playlistSuggestion: String = ""
    
    var body: some View {
        VStack {
            Button("Pick Image") {
                isPickerPresented = true
            }
            
            if !playlistSuggestion.isEmpty {
                Text(playlistSuggestion)
                    .padding()
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
                    guard let apiKey else { return }
                    
                    if let imageData = selectedImageData {
                        let base64String = imageData.toBase64()
                        // Now, you can use `base64String` for your API call
                        let messages = [
                            VisionRequest.Message(
                                role: "user",
                                content: [
                                    VisionRequest.Message.Content(
                                        type: "text",
                                        text: "Generate a playlist from this image",
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
