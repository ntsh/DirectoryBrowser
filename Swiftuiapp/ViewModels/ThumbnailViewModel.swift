import Foundation
import QuickLook

class ThumbnailViewModel: ObservableObject {
    @Published var thumbnail: CGImage?
    @Published var imageLabel = "Thumbnail"

    func generateThumbnail(_ url: URL) {
        let size: CGSize = CGSize(width: 400, height: 400)
        let request = QLThumbnailGenerator.Request(fileAt: url, size: size, scale: (UIScreen.main.scale), representationTypes: .all)
        let generator = QLThumbnailGenerator.shared

        generator.generateRepresentations(for: request) { (thumbImage, type, error) in
            DispatchQueue.main.async {
                if thumbImage == nil || error != nil {
                    // TODO: Default icon
                } else {
                    self.thumbnail = thumbImage!.cgImage
                }
            }
        }
    }
}
