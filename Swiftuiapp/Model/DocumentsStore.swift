import Foundation

func loadDocuments() -> [Document] {
    guard let docDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        return []
    }

    var allDocuments: [Document] = []
    do {
        let allFiles = try FileManager.default.contentsOfDirectory(atPath: docDirectory.path)

        allDocuments = allFiles.map { (fileName) -> Document in
            var url = docDirectory
            url = url.appendingPathComponent(fileName)
            var created, modified: Date?
            var size: NSNumber = 0
            do {
                let attr = try FileManager.default.attributesOfItem(atPath: url.relativePath)
                created = attr[FileAttributeKey.creationDate] as? Date
                modified = attr[FileAttributeKey.modificationDate] as? Date
                size = attr[FileAttributeKey.size] as? NSNumber ?? 0
            } catch let error as NSError {
                NSLog("Error reading file attr: \(error)")
            }

            return Document(name: fileName, url: url, size: size, created: created, modified: modified)
        }
    } catch let error as NSError {
        NSLog("Error traversing files directory: \(error)")
    }

    return allDocuments
}


class DocumentsStore: ObservableObject {
    @Published var documents: [Document] = loadDocuments()

    func reload() {
        documents = loadDocuments()
    }

    func delete(_ document: Document) {
        do {
            try FileManager.default.removeItem(at: document.url)
            // Find current document and remove from documents array
            if let index = documents.firstIndex(where: { $0.url == document.url }) {
                documents.remove(at: index)
            }
        } catch let error as NSError {
            NSLog("Error deleting file: \(error)")
        }
    }
}

class DocumentsStore_Preview: DocumentsStore {
    override var documents: [Document] {
        set {
            super.documents = newValue
        }
        get {
            return  [Document(name: "Hello.pdf", url: URL(string: "/")!, size:1700, created: Date()),
                     Document(name: "Travel documentation list.txt", url: URL(string: "/")!, size:100000, created: Date().addingTimeInterval(-30000))]
        }
    }
}
