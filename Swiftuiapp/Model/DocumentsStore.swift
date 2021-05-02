import Foundation

enum DocumentsStoreError: Error {
    case fileExists
}

class DocumentsStore: ObservableObject {
    @Published var documents: [Document] = []

    private var relativePath: String

    private var workingDirectory: URL? {
        guard let docDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        return docDirectory.appendingPathComponent(relativePath)
    }

    init(relativePath: String) {
        self.relativePath = relativePath
        documents = loadDocuments()
    }

    func loadDocuments() -> [Document] {
        guard let docDirectory = workingDirectory else {
            return []
        }

        var allDocuments: [Document?] = []
        do {
            let attrKeys: [URLResourceKey] = [.nameKey, .fileSizeKey, .contentModificationDateKey, .creationDateKey, .isDirectoryKey]
            let allFiles = try FileManager.default.contentsOfDirectory(at: docDirectory,
                                                                       includingPropertiesForKeys: attrKeys,
                                                                       options: [.skipsHiddenFiles])

            allDocuments = allFiles.map { (url) -> Document? in
                var document: Document? = nil
                do {
                    let attrVals = try url.resourceValues(forKeys: Set(attrKeys))
                    let fileName = attrVals.name ?? ""
                    let created = attrVals.creationDate
                    let modified = attrVals.contentModificationDate
                    let size = NSNumber(value: attrVals.fileSize ?? 0)
                    let isDirectory = attrVals.isDirectory ?? false

                    document = Document(name: fileName, url: url, size: size, created: created, modified: modified, isDirectory: isDirectory)
                } catch let error as NSError {
                    NSLog("Error reading file attr: \(error)")
                }
                return document
            }
        } catch let error as NSError {
            NSLog("Error traversing files directory: \(error)")
        }

        return allDocuments.compactMap { $0 }
    }

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

    func createFolder(_ name: String) throws {
        guard let docDirectory = workingDirectory else {
            return
        }

        let target = docDirectory.appendingPathComponent(name, isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: target, withIntermediateDirectories: false, attributes: nil)
            reload()
        } catch CocoaError.fileWriteFileExists {
            throw DocumentsStoreError.fileExists
        }
    }

    func importFile(from url: URL) {
        guard let docDirectory = workingDirectory else {
            return
        }
        var suitableUrl = docDirectory.appendingPathComponent(url.lastPathComponent)

        var retry = true
        var retryCount = 1
        while retry {
            retry = false

            do {
                try FileManager.default.copyItem(at: url, to: suitableUrl)
            } catch CocoaError.fileWriteFileExists {
                retry = true

                // append (1) to file name
                let fileExtension = url.pathExtension
                let fileNameWithoutExtension = url.deletingPathExtension().lastPathComponent
                let fileNameWithCountSuffix = fileNameWithoutExtension.appending(" (\(retryCount))")
                suitableUrl = docDirectory.appendingPathComponent(fileNameWithCountSuffix).appendingPathExtension(fileExtension)

                retryCount += 1

                NSLog("Retry *** suitableName = \(suitableUrl.lastPathComponent)")
            } catch let error as NSError {
                NSLog("Error importing file: \(error)")
            }
        }
    }

    func relativePath(for document: Document) -> String {
        let url = URL(fileURLWithPath: document.name, isDirectory: document.isDirectory, relativeTo: URL(fileURLWithPath: relativePath, isDirectory: true)).path
        return url
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
