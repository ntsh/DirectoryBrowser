import SwiftUI

struct DocumentDetails: View {
    @State private var showingPreview = false
    var document: Document

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            List {
                ThumbnailView(url: document.url)
                    .padding(.vertical)
                    .onTapGesture {
                        self.showingPreview = true
                    }

                HStack {
                    Spacer()
                    Text(document.name)
                        .multilineTextAlignment(.center)
                        .font(.headline)
                    Spacer()
                }

                DocumentAttributeRow(key: "Size", value: DocumentSizeFormatter.string(fromByteCount: Int64(truncating: document.size)))

                if let created = document.created {
                    DocumentAttributeRow(key: "Created", value: ShortTimestampFormatter.string(from: created))
                }

                if let modified = document.modified {
                    DocumentAttributeRow(key: "Modified", value: ShortTimestampFormatter.string(from: modified))
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .sheet(isPresented: $showingPreview) {
            PreviewController(url: document.url, isPresented: self.$showingPreview)
        }
        .navigationBarItems(trailing: HStack {
            Button(action: { self.showingPreview = true }) {
                Image(systemName: "play.fill")
                    .font(.largeTitle)
            }.foregroundColor(.blue)
        })
    }
}

struct DocumentDetails_Previews: PreviewProvider {
    static var previews: some View {
        DocumentDetails(document: DocumentsStore_Preview(relativePath: "/", sorting: .date(ascending: true)).documents[1])
            .preferredColorScheme(.dark)
            .environment(\.sizeCategory, .large)
    }
}
