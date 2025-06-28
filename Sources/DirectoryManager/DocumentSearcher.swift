import Foundation

public struct DocumentSearchResult: Identifiable, Hashable {
    public var id = UUID()
    public var document: Document
    public var root: URL

    public init(document: Document, root: URL) {
        self.document = document
        self.root = root
    }
}

@MainActor
public class DocumentSearcher: ObservableObject {
    @Published public private(set) var results: [DocumentSearchResult] = []

    private let roots: [URL]
    private let documentManager: DocumentManager
    private let attrKeys: [URLResourceKey] = [.nameKey, .fileSizeKey, .contentModificationDateKey, .creationDateKey, .isDirectoryKey]

    public init(roots: [URL], documentManager: DocumentManager = FileManager.default) {
        self.roots = roots
        self.documentManager = documentManager
    }

    public func search(query: String) {
        results.removeAll()
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let lowercased = trimmed.lowercased()
        for root in roots {
            searchDirectory(root, root: root, query: lowercased)
        }
    }

    public func clear() {
        results.removeAll()
    }

    private func searchDirectory(_ directory: URL, root: URL, query: String) {
        guard let contents = try? documentManager.contentsOfDirectory(at: directory) else { return }
        for url in contents {
            if let doc = document(from: url), doc.name.lowercased().contains(query) {
                results.append(DocumentSearchResult(document: doc, root: root))
            }
            if docIsDirectory(url) {
                searchDirectory(url, root: root, query: query)
            }
        }
    }

    private func docIsDirectory(_ url: URL) -> Bool {
        (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
    }

    private func document(from url: URL) -> Document? {
        do {
            let attrVals = try url.resourceValues(forKeys: Set(attrKeys))
            let fileName = attrVals.name ?? url.lastPathComponent
            let created = attrVals.creationDate
            let modified = attrVals.contentModificationDate
            let size = NSNumber(value: attrVals.fileSize ?? 0)
            let isDirectory = attrVals.isDirectory ?? false

            return Document(name: fileName, url: url, size: size, created: created, modified: modified, isDirectory: isDirectory)
        } catch {
            return nil
        }
    }
}
