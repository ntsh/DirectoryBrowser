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
        return Int(truncating: document.size).formatted(ByteCountFormatStyle())
    }

    var documentCreated: String? {
        if let created = document.created {
            return created.formatted()
        }
        return nil
    }

    var documentModified: String? {
        if let modified = document.modified {
            return modified.formatted()
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
