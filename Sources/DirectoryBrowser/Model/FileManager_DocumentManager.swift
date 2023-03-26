import Foundation

/// Thin wrapper around FileManager, conforming to the DoucmentManagerProtocol
extension FileManager: DocumentManager {
    public func contentsOfDirectory(at url: URL) throws -> [URL] {
        let attrKeys: [URLResourceKey] = [.nameKey, .fileSizeKey, .contentModificationDateKey, .creationDateKey, .isDirectoryKey]

        return try contentsOfDirectory(at: url, includingPropertiesForKeys: attrKeys, options: [.skipsHiddenFiles])
    }

    public func createDirectory(at url: URL) throws {
        try createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
    }
}
