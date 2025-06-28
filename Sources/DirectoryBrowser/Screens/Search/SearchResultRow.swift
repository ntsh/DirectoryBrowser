import DirectoryManager
import SwiftUI

struct SearchResultRow: View {
    var result: DocumentSearchResult

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: result.document.isDirectory ? "folder" : "doc")
            VStack(alignment: .leading) {
                Text(result.document.name)
                Text(humanReadablePath(for: result.document.url, root: result.root))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
