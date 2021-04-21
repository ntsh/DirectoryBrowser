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

                AttributeView(key: "Size", value: sizeFormatter.string(fromByteCount: Int64(truncating: document.size)))

                if let created = document.created {
                    AttributeView(key: "Created", value: itemFormatter.string(from: created))
                }

                if let modified = document.modified {
                    AttributeView(key: "Modified", value: itemFormatter.string(from: modified))
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
        DocumentDetails(document: DocumentsStore_Preview().documents[1])
            .preferredColorScheme(.dark)
            .environment(\.sizeCategory, .large)
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

private let sizeFormatter: ByteCountFormatter = {
    let formatter = ByteCountFormatter()
    formatter.isAdaptive = false
    formatter.countStyle = .file
    return formatter
}()

struct AttributeView: View {
    var key, value: String

    var body: some View {
        HStack {
            Text(key)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
    }
}
