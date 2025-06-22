import DirectoryManager
import FilePreviews
import SwiftUI

struct DocumentDetails: View {
    var document: Document

    @State private var urlToPreview: URL?
    @State private var isShowingShareSheet = false
    @State private var showShareSuccess = false

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
        }
        .quickLookPreview($urlToPreview)
#if os(iOS)
        .listStyle(InsetGroupedListStyle())
        .navigationBarItems(trailing: HStack {
            Button(action: showPreview) {
                Image(systemName: "play.fill")
            }.foregroundColor(.blue)
            Button(action: { isShowingShareSheet = true }) {
                Image(systemName: "square.and.arrow.up")
            }.foregroundColor(.blue)
        })
        .sheet(isPresented: $isShowingShareSheet) {
            ShareSheet(activityItems: [document.url]) { activityType, completed, _, error in
                if completed {
                    print("Share successful via: \(activityType?.rawValue ?? "unknown")")
                    withAnimation { showShareSuccess = true }
                } else if let error = error {
                    print("Share failed via: \(activityType?.rawValue ?? "unknown"). Error: \(error)")
                } else {
                    print("Share cancelled or failed via: \(activityType?.rawValue ?? "unknown")")
                }
            }
        }
        .toast(isShowing: $showShareSuccess, message: "Shared successfully")
#endif
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
