import DirectoryManager
import SwiftUI
import FilePreviews

/// SwiftUI view providing a navigation interface to browse application directories.
public struct DirectoryBrowser: View {
    @StateObject var thumbnailer = Thumbnailer()
    private var urls: [URL]
    @State private var confirmDelete: Bool
    @State private var showSettings = false
    @State private var searchText = ""
    @StateObject private var searcher: DocumentSearcher

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
        _searcher = StateObject(wrappedValue: DocumentSearcher(roots: urls))
    }

    public var body: some View {
        NavigationView {
            Group {
                if searcher.results.isEmpty && searchText.isEmpty {
                    List(urls) { url in
                        NavigationLink(url.lastPathComponent) {
                            FolderView(documentsStore: DocumentsStore(root: url), title: url.lastPathComponent)
                        }
                    }
                } else {
                    SearchResultsView(searcher: searcher)
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
            .searchable(text: $searchText)
            .onSubmit(of: .search) { searcher.search(query: searchText) }
            .onChange(of: searchText) { if $0.isEmpty { searcher.clear() } }
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
