import Foundation
import QuickLook

class ThumbnailViewModel: ObservableObject {
    @Published var thumbnail: CGImage?
    @Published var imageLabel = "Thumbnail"

    func generateThumbnail(_ url: URL) {
        let size: CGSize = CGSize(width: 400, height: 400)
        let request = QLThumbnailGenerator.Request(fileAt: url, size: size, scale: (UIScreen.main.scale), representationTypes: .all)
        let generator = QLThumbnailGenerator.shared

        Task {
            let representation = try? await generator.generateBestRepresentation(for: request) // TODO: Default icon?
            DispatchQueue.main.sync {
                thumbnail = representation?.cgImage
            }
        }
    }
}
