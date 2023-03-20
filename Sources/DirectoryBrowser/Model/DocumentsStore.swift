import Foundation

enum DocumentsStoreError: Error {
    case fileExists
}

protocol DocumentImporter {
    func importFile(from url: URL) async
}

@MainActor
public class DocumentsStore: ObservableObject, DocumentImporter {
    @Published var documents: [Document] = []
    @Published var sorting: SortOption = .date(ascending: false) //TODO: Get it from userdefaults

    private var relativePath: String
    private var documentManager: DocumentManagerProtocol
    private let attrKeys: [URLResourceKey] = [.nameKey, .fileSizeKey, .contentModificationDateKey, .creationDateKey, .isDirectoryKey]

    private var workingDirectory: URL? {
        guard let docDirectory = documentManager.documentDirectory() else {
            return nil
        }
        guard relativePath.count > 0 else {
            return docDirectory
        }

        return docDirectory.appendingPathComponent(relativePath)
    }

    public init(relativePath: String = "", sorting: SortOption = .date(ascending: true), documentsSource: DocumentManagerProtocol = DocumentManager()) {
        self.relativePath = relativePath
        self.sorting = sorting
        self.documentManager = documentsSource
    }

    fileprivate func document(from url: URL) -> Document? {
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

    func loadDocuments() {
        guard let docDirectory = workingDirectory else {
            documents = []
            return
        }

        do {
            let allFiles = try documentManager.contentsOfDirectory(at: docDirectory)
            documents = allFiles.map { document(from: $0) }.compactMap{ $0 }
        } catch let error as NSError {
            NSLog("Error traversing files directory: \(error)")
        }

        sort()
    }

    func reload() {
        loadDocuments()
    }

    fileprivate func sort() {
        documents.sort(by: sorting.sortingComparator())
    }

    func setSorting(_ sorting: SortOption) {
        self.sorting = sorting

        sort()
    }

    func delete(_ document: Document) {
        do {
            try documentManager.removeItem(at: document.url)
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
            try documentManager.createDirectory(at: target)
            if let folder = document(from: target) {
                documents.insert(folder, at: 0)
                sort()
            }
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
                try documentManager.copyItem(at: url, to: suitableUrl)

                if let document = document(from: suitableUrl) {
                    documents.insert(document, at: self.documents.endIndex)
                    sort()
                }
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

    func rename(document: Document, newName: String) throws {
        guard let docDirectory = workingDirectory else {
            return
        }

        let newUrl = docDirectory.appendingPathComponent(newName, isDirectory: document.isDirectory)
        do {
            try documentManager.moveItem(at: document.url, to: newUrl)

            // Find current document in documents array and update the values
            if let indexToUpdate = documents.firstIndex(where: { $0.url == document.url }) {
                var documentToUpdate = documents[indexToUpdate]
                documents.remove(at: indexToUpdate)

                documentToUpdate.url = newUrl
                documentToUpdate.name = newName
                documents.insert(documentToUpdate, at: 0)

                sort()
            }
        } catch CocoaError.fileWriteFileExists {
            throw DocumentsStoreError.fileExists
        }
    }
}

class DocumentsStore_Preview: DocumentsStore {
    override var documents: [Document] {
        set {
            super.documents = newValue
        }
        get {
            return  [Document(name: "Hello.pdf", url: URL(string: "/")!, size:1700, modified: Date()),
                     Document(name: "Travel documentation list.txt", url: URL(string: "/")!, size:100000, modified: Date().addingTimeInterval(-30000))]
        }
    }
}
