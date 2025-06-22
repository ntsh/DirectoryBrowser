import DirectoryManager
import SwiftUI
import FilePreviews

/// SwiftUI view providing a navigation interface to browse application directories.
public struct DirectoryBrowser: View {
    @StateObject var thumbnailer = Thumbnailer()
    private var urls: [URL]
    @State private var confirmDelete: Bool
    @State private var showSettings = false

    /// Creates a new browser for the specified directories.
    /// - Parameters:
    ///   - urls: Directories that will be presented at the top level.
    ///   - confirmDelete: Flag controlling whether deletions require confirmation.
    public init(
        urls: [URL] = [.documentsDirectory, .libraryDirectory, .temporaryDirectory],
        confirmDelete: Bool = true
    ) {
        self.urls = urls
        _confirmDelete = State(initialValue: confirmDelete)
    }

    public var body: some View {
        NavigationView {
            List(urls) { url in
                NavigationLink(url.lastPathComponent) {
                    FolderView(documentsStore: DocumentsStore(root: url), title: url.lastPathComponent)
                }
            }
            .navigationTitle("Directories")
#if os(iOS)
            .navigationBarItems(trailing:
                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape")
                }
            )
#endif
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(confirmDelete: $confirmDelete)
        }
        .environmentObject(thumbnailer)
        .environment(\.confirmDelete, confirmDelete)
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
