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
            return Document(name: fileName, url: url, date: Date())
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
}

class DocumentsStore_Preview: DocumentsStore {
    override var documents: [Document] {
        set {
            super.documents = newValue
        }
        get {
            return  [Document(name: "Hello.pdf", url: URL(string: "/")!, date: Date()),
                     Document(name: "Travel documentation list.txt", url: URL(string: "/")!, date: Date().addingTimeInterval(-30000))]
        }
    }
}
