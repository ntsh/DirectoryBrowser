import FilePreviews
import SwiftUI

struct DocumentRow: View {
    @State var document: Document
    var deleteDocument: () -> ()
    var editDocumentName: () -> ()

    var body: some View {
        HStack (alignment: .top, spacing: 16) {
            ThumbnailView(url: document.url)
                .frame(width: 60, height: 60, alignment: .center)
                .clipped()
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 12 ) {
                Text(document.name)
                    .font(.headline)
                    .lineLimit(2)
                    .allowsTightening(true)

                if let modified = document.modified {
                    Text(modified.formatted())
                        .font(.subheadline)
                        .lineLimit(1)
                        .allowsTightening(true)
                        .minimumScaleFactor(0.5)
                }
            }
        }
        .contextMenu {
            Button(action: deleteDocument) {
                Label("Delete", systemImage: "trash")
            }
            Button(action: editDocumentName) {
                Label("Rename", systemImage: "pencil")
            }
            Button(action: {}) {
                Label("Move", systemImage: "folder.badge.gear")
            }
            Button(action: {}) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
        }
    }
}

struct DocumentRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DocumentRow(
                document: DocumentsStore_Preview(
                    root: URL.temporaryDirectory,
                    relativePath: "/", sorting: .date(ascending: true)
                ).documents[1],
                deleteDocument: {},
                editDocumentName: {}
            )
            .environment(\.sizeCategory, .large)
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
        }
    }
}
