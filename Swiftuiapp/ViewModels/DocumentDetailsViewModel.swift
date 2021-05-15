import Foundation

class DocumentDetailsViewModel: ObservableObject {

    private var document: Document

    @Published var showingPreview = false

    init(document: Document) {
        self.document = document
    }

    var documentName: String {
        document.name
    }

    var documentSize: String {
        DocumentSizeFormatter.string(fromByteCount: Int64(truncating: document.size))
    }

    var documentCreated: String? {
        if let created = document.created {
            return ShortTimestampFormatter.string(from: created)
        }
        return nil
    }

    var documentModified: String? {
        if let modified = document.modified {
            return ShortTimestampFormatter.string(from: modified)
        }
        return nil
    }

    var documentUrl: URL {
        document.url
    }

    func showPreview() {
        showingPreview = true
    }
}
