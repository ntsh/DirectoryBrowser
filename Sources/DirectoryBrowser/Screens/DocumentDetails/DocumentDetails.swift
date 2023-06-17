import DirectoryManager
import FilePreviews
import SwiftUI

struct DocumentDetails: View {
    var document: Document

    @State private var urlToPreview: URL?

    public init(document: Document) {
        self.document = document
    }

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            List {
                ThumbnailView(url: document.url)
                    .padding(.vertical)
                    .onTapGesture(perform: showPreview)

                HStack {
                    Spacer()
                    Text(document.name)
                        .multilineTextAlignment(.center)
                        .font(.headline)
                    Spacer()
                }

                DocumentAttributeRow(key: "Size", value: document.formattedSize)

                if let created = document.created {
                    DocumentAttributeRow(key: "Created", value: created.formatted())
                }

                if let modified = document.modified {
                    DocumentAttributeRow(key: "Modified", value: modified.formatted())
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .quickLookPreview($urlToPreview)
        .navigationBarItems(trailing: HStack {
            Button(action: showPreview) {
                Image(systemName: "play.fill")
                    .font(.largeTitle)
            }.foregroundColor(.blue)
        })
    }

    func showPreview() {
        urlToPreview = document.url
    }
}

struct DocumentDetails_Previews: PreviewProvider {
    static var previews: some View {
        DocumentDetails(document: DocumentsStore_Preview(root: URL.temporaryDirectory, relativePath: "/", sorting: .date(ascending: true)).documents[1])
            .preferredColorScheme(.dark)
            .environment(\.sizeCategory, .large)
    }
}
