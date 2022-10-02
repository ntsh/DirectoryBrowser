import SwiftUI

public struct ThumbnailView: View {
    public let url: URL

    @StateObject var thumbnailer = Thumbnailer()

    public init(url: URL) {
        self.url = url
    }

    public var body: some View {
        Group {
            if let thumbnail = thumbnailer.thumbnail {
                Image(thumbnail, scale: (UIScreen.main.scale), label: Text(thumbnailer.imageLabel))
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(contentMode: .fill)
            } else {
                Image(systemName: "photo.fill")
                    .onAppear {
                        thumbnailer.generateThumbnail(url)
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

