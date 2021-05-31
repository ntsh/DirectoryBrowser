import Foundation

/// Thin wrapper around FileManager, conforming to the DoucmentManagerProtocol
class DocumentManager: DocumentManagerProtocol {

    private let fileManager = FileManager.default

    private let attrKeys: [URLResourceKey] = [.nameKey, .fileSizeKey, .contentModificationDateKey, .creationDateKey, .isDirectoryKey]

    func documentDirectory() -> URL? {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }

    func contentsOfDirectory(at url: URL) throws -> [URL] {
        return try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: attrKeys, options: [.skipsHiddenFiles])
    }

    func removeItem(at url: URL) throws {
        try fileManager.removeItem(at: url)
    }

    func createDirectory(at url: URL) throws {
        try fileManager.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
    }

    func copyItem(at source: URL, to destination: URL) throws {
        try fileManager.copyItem(at: source, to: destination)
    }

    func moveItem(at source: URL, to destination: URL) throws {
        try fileManager.moveItem(at: source, to: destination)
    }
}
