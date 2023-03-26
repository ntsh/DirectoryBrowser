import SwiftUI
import FilePreviews

public struct DirectoryBrowser: View {
    @ObservedObject var documentsStore: DocumentsStore
    @StateObject var thumbnailer = Thumbnailer()

    public init(documentsStore: DocumentsStore) {
        self.documentsStore = documentsStore
    }

    public var body: some View {
        NavigationView {
            FolderView(documentsStore: documentsStore, title: "Documents")
        }
        .environmentObject(thumbnailer)
    }
}

struct DirectoryBrowser_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DirectoryBrowser(documentsStore: DocumentsStore_Preview(root: URL.temporaryDirectory ,relativePath: "/", sorting: .date(ascending: true)))
                .preferredColorScheme(.light)

            DirectoryBrowser(documentsStore: DocumentsStore_Preview(root: URL.temporaryDirectory, relativePath: "/", sorting: .date(ascending: true)))
                .preferredColorScheme(.dark)
        }
    }
}
