import Foundation
import UIKit

extension UIImage {

    /// Returns filename to be saved in DB
    static func downloadAndSaveImage(from url: URL) async throws -> String {
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw NSError(
                domain: "ImageDownloadError",
                code: 0,
                userInfo: [
                    NSLocalizedDescriptionKey: "Failed to create image from downloaded data."
                ]
            )
        }

        guard
            let documentsDirectory = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first
        else {
            throw NSError(
                domain: "FileSaveError",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Cannot find documents directory."]
            )
        }

        let filename = UUID().uuidString + ".png"
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        guard let imageData = image.pngData() else {
            throw NSError(
                domain: "ImageConversionError",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to PNG data."]
            )
        }

        try imageData.write(to: fileURL)
        return filename 
    }
}
