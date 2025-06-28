import DirectoryManager
import SwiftUI

struct SearchResultsView: View {
    @ObservedObject var searcher: DocumentSearcher

    var body: some View {
        List(searcher.results) { result in
            NavigationLink(destination: destination(for: result)) {
                SearchResultRow(result: result)
            }
        }
    }

    @ViewBuilder
    private func destination(for result: DocumentSearchResult) -> some View {
        if result.document.isDirectory {
            let rel = relativePath(for: result.document.url, root: result.root)
            FolderView(documentsStore: DocumentsStore(root: result.root, relativePath: rel), title: result.document.name)
        } else {
            DocumentDetails(document: result.document)
        }
    }
}
