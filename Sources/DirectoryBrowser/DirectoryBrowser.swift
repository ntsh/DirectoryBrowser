import DirectoryManager
import SwiftUI
import FilePreviews

public struct DirectoryBrowser: View {
    @StateObject var thumbnailer = Thumbnailer()
    private var urls: [URL]

    public init(
        urls: [URL] = [.documentsDirectory, .libraryDirectory, .temporaryDirectory]
    ) {
        self.urls = urls
    }

    public var body: some View {
        NavigationView {
            List(urls) { url in
                NavigationLink(url.lastPathComponent) {
                    FolderView(documentsStore: DocumentsStore(root: url), title: url.lastPathComponent)
                }
            }
        }
        .environmentObject(thumbnailer)
    }
}

struct DirectoryBrowser_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DirectoryBrowser()
                .preferredColorScheme(.light)

            DirectoryBrowser()
                .preferredColorScheme(.dark)
        }
    }
}
