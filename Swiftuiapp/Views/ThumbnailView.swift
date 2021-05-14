import SwiftUI
import QuickLook

struct ThumbnailView: View {
    let url: URL

    @StateObject var viewModel = ThumbnailViewModel()

    var body: some View {
        Group {
            if let thumbnail = viewModel.thumbnail {
                Image(thumbnail, scale: (UIScreen.main.scale), label: Text("Thumbnail"))
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(contentMode: .fill)
            } else {
                Image(systemName: "photo.fill")
                    .onAppear(perform: {
                        viewModel.generateThumbnail(url)
                    })
            }
        }
    }
}

extension ThumbnailView {
    class ThumbnailViewModel: ObservableObject {
        @Published var thumbnail: CGImage?

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
}

struct ThumbnailView_Preview: PreviewProvider {
    static var previews: some View {
        ThumbnailView(url: URL(fileURLWithPath: ""))
    }
}

