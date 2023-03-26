import Foundation

/// Protocol defining the functions related to documents operation
public protocol DocumentManager {
    func contentsOfDirectory(at url: URL) throws -> [URL]
    func removeItem(at url: URL) throws
    func createDirectory(at url: URL) throws
    func copyItem(at source: URL, to destination: URL) throws
    func moveItem(at source: URL, to destination: URL) throws
}
