import Foundation

/// Error values thrown by ``DocumentsStore`` operations.
public enum DocumentsStoreError: Error, LocalizedError {
    /// An item with the same name already exists.
    case fileExists
    /// The referenced file no longer exists on disk.
    case fileWasDeleted
    /// A generic unknown failure occurred.
    case unknown
}

/// Type responsible for importing external files.
public protocol DocumentImporter {
    /// Imports a file located at the given URL and returns the created ``Document``.
    /// - Parameter url: Source location of the file.
    /// - Returns: Newly created ``Document`` or `nil` if import failed.
    @discardableResult func importFile(from url: URL) async -> Document?
}

@MainActor
/// Observable object that loads and manipulates documents from a directory.
public class DocumentsStore: ObservableObject, DocumentImporter {
    /// Current list of ``Document`` objects available in the directory.
    @Published public var documents: [Document] = []
    /// Current sorting preference used when displaying documents.
    @Published public var sorting: SortOption = .date(ascending: false) //TODO: Get it from userdefaults

    /// Root directory being browsed.
    public var docDirectory: URL
    private var relativePath: String
    private var documentManager: DocumentManager
    private let attrKeys: [URLResourceKey] = [.nameKey, .fileSizeKey, .contentModificationDateKey, .creationDateKey, .isDirectoryKey]

    /// Directory being operated on taking into account the relative path.
    private var workingDirectory: URL {
        guard relativePath.count > 0 else {
            return docDirectory
        }

        return docDirectory.appendingPathComponent(relativePath)
    }

    /// Creates a store pointing to the provided root directory.
    /// - Parameters:
    ///   - root: Base directory to manage.
    ///   - relativePath: Optional subdirectory relative to `root`.
    ///   - sorting: Initial ``SortOption`` to apply.
    ///   - documentsSource: Implementation used to perform file system operations.
    public init(
        root: URL,
        relativePath: String = "",
        sorting: SortOption = .date(ascending: true),
        documentsSource: DocumentManager = FileManager.default
    ) {
        docDirectory = root
        self.relativePath = relativePath
        self.sorting = sorting
        self.documentManager = documentsSource
    }

    /// Creates a ``Document`` instance from a file URL.
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

    /// Loads the contents of ``workingDirectory`` into ``documents``.
    public func loadDocuments() {
        do {
            let allFiles = try documentManager.contentsOfDirectory(at: workingDirectory)
            documents = allFiles.map { document(from: $0) }.compactMap{ $0 }
        } catch let error as NSError {
            NSLog("Error traversing files directory: \(error)")
        }

        sort()
    }

    /// Reloads the directory contents.
    public func reload() {
        loadDocuments()
    }

    /// Sorts ``documents`` according to ``sorting``.
    fileprivate func sort() {
        documents.sort(by: sorting.sortingComparator())
    }

    /// Updates the sorting preference.
    /// - Parameter sorting: New option to use.
    public func setSorting(_ sorting: SortOption) {
        self.sorting = sorting

        sort()
    }

    /// Deletes a document from disk and removes it from ``documents``.
    /// - Parameter document: The item to delete.
    public func delete(_ document: Document) {
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

    /// Creates a new uniquely named folder in the current directory.
    /// - Returns: The created folder as a ``Document``.
    @discardableResult
    public func createNewFolder() throws -> Document {
        var folderName = "New Folder"
        var folderNumber = 0
        var folderUrl = workingDirectory.appendingPathComponent(folderName, isDirectory: true)
        // Check if a folder with the name already exists
        while documentManager.fileExists(atPath: folderUrl.relativePath) {
            folderNumber += 1
            folderName = "New Folder (\(folderNumber))"
            folderUrl = workingDirectory.appendingPathComponent(folderName, isDirectory: true)
        }

        // Create the new folder
        do {
            return try createFolder(folderName)
        } catch {
            print("Error creating new folder \(error)")
            throw DocumentsStoreError.unknown
        }
    }

    /// Creates a folder with the provided name.
    /// - Parameter name: Folder name.
    /// - Returns: The created folder document.
    @discardableResult
    public func createFolder(_ name: String) throws -> Document {
        let target = workingDirectory.appendingPathComponent(name, isDirectory: true)
        do {
            try documentManager.createDirectory(at: target)
        } catch CocoaError.fileWriteFileExists {
            throw DocumentsStoreError.fileExists
        }

        if let folder = document(from: target) {
            documents.insert(folder, at: 0)
            sort()
            return folder
        } else {
            throw DocumentsStoreError.unknown
        }
    }

    /// Imports a file from the given URL into the current directory.
    /// - Parameter url: Location of the file to copy.
    /// - Returns: The new ``Document`` instance or `nil`.
    @discardableResult
    public func importFile(from url: URL) -> Document? {
        var suitableUrl = workingDirectory.appendingPathComponent(url.lastPathComponent)

        var retry = true
        var retryCount = 1
        while retry {
            retry = false

            do {
                try documentManager.copyItem(at: url, to: suitableUrl)
            } catch CocoaError.fileWriteFileExists {
                retry = true

                // append (1) to file name
                let fileExtension = url.pathExtension
                let fileNameWithoutExtension = url.deletingPathExtension().lastPathComponent
                let fileNameWithCountSuffix = fileNameWithoutExtension.appending(" (\(retryCount))")
                suitableUrl = workingDirectory.appendingPathComponent(fileNameWithCountSuffix).appendingPathExtension(fileExtension)

                retryCount += 1

                NSLog("Retry *** suitableName = \(suitableUrl.lastPathComponent)")
            } catch let error as NSError {
                NSLog("Error importing file: \(error)")
            }
        }
        if let document = document(from: suitableUrl) {
            documents.insert(document, at: self.documents.endIndex)
            sort()
            return document
        } else {
            return nil
        }
    }

    /// Returns the path of a document relative to the store's root directory.
    /// - Parameter document: The document whose relative path should be computed.
    public func relativePath(for document: Document) -> String {
        let url = URL(fileURLWithPath: document.name, isDirectory: document.isDirectory, relativeTo: URL(fileURLWithPath: "/\(relativePath)", isDirectory: true)).path
        return url
    }

    /// Renames an existing document.
    /// - Parameters:
    ///   - document: The document to rename.
    ///   - newName: Desired new name for the document.
    /// - Returns: Updated ``Document`` instance.
    @discardableResult
    public func rename(document: Document, newName: String) throws -> Document {
        let newUrl = workingDirectory.appendingPathComponent(newName, isDirectory: document.isDirectory)
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
                return documentToUpdate
            } else {
                throw DocumentsStoreError.fileWasDeleted
            }
        } catch CocoaError.fileWriteFileExists {
            throw DocumentsStoreError.fileExists
        }
    }
}

public class DocumentsStore_Preview: DocumentsStore {
    override public var documents: [Document] {
        set {
            super.documents = newValue
        }
        get {
            return  [Document(name: "Hello.pdf", url: URL(string: "/")!, size:1700, modified: Date()),
                     Document(name: "Travel documentation list.txt", url: URL(string: "/")!, size:100000, modified: Date().addingTimeInterval(-30000))]
        }
    }
}
