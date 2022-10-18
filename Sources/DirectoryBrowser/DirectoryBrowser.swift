import SwiftUI

public struct DirectoryBrowser: View {
    @ObservedObject var documentsStore: DocumentsStore

    public init(documentsStore: DocumentsStore) {
        self.documentsStore = documentsStore
    }

    public var body: some View {
        NavigationView {
            FolderView(documentsStore: documentsStore, title: "Documents")
        }
    }
}

struct DirectoryBrowser_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DirectoryBrowser(documentsStore: DocumentsStore_Preview(relativePath: "/", sorting: .date(ascending: true)))
                .preferredColorScheme(.light)

            DirectoryBrowser(documentsStore: DocumentsStore_Preview(relativePath: "/", sorting: .date(ascending: true)))
                .preferredColorScheme(.dark)
        }
    }
}
