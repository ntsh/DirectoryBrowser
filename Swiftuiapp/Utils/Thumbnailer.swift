import Foundation
import QuickLook

@MainActor
class Thumbnailer: ObservableObject {
    @Published var thumbnail: CGImage?
    @Published var imageLabel = "Thumbnail" // Potentially generate this based on image content

    func generateThumbnail(_ url: URL, size: CGSize = CGSize(width: 400, height: 400)) {
        let request = QLThumbnailGenerator.Request(fileAt: url, size: size, scale: (UIScreen.main.scale), representationTypes: .all)
        let generator = QLThumbnailGenerator.shared

        Task {
            let representation = try? await generator.generateBestRepresentation(for: request) // TODO: Default icon?
            thumbnail = representation?.cgImage
        }
    }
}
