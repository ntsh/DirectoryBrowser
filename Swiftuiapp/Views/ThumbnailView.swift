import SwiftUI
import QuickLook

struct ThumbnailView: View {
    let url: URL

    @State private var thumbnail: CGImage? = nil

    var body: some View {
        Group {
            if thumbnail != nil {
                Image(self.thumbnail!, scale: (UIScreen.main.scale), label: Text("PDF"))
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(contentMode: .fill)
            } else {
                Image(systemName: "photo.fill").onAppear(perform: generateThumbnail)
            }
        }
    }

    func generateThumbnail() {
        let size: CGSize = CGSize(width: 400, height: 400)
        let request = QLThumbnailGenerator.Request(fileAt: url, size: size, scale: (UIScreen.main.scale), representationTypes: .all)
        let generator = QLThumbnailGenerator.shared

        generator.generateRepresentations(for: request) { (thumbnail, type, error) in
            DispatchQueue.main.async {
                if thumbnail == nil || error != nil {
                    // TODO: Default icon
                } else {
                    DispatchQueue.main.async {
                        self.thumbnail = thumbnail!.cgImage
                    }
                }
            }
        }
    }
}
//
//struct ThumbnailView_Preview: PreviewProvider {
//    static var previews: some View {
//        ThumbnailView(url: URL)
//    }
//}
//
