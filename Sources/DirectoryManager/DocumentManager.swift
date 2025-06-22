import Foundation

/// Protocol describing file management operations required by `DocumentsStore`.
public protocol DocumentManager {

    /// Returns the URLs of the items contained in the specified directory.
    func contentsOfDirectory(at url: URL) throws -> [URL]

    /// Removes the item at the given URL.
    func removeItem(at url: URL) throws

    /// Creates a directory at the provided URL.
    func createDirectory(at url: URL) throws

    /// Copies an item from a source URL to the destination URL.
    func copyItem(at source: URL, to destination: URL) throws

    /// Moves an item from the source URL to the destination URL.
    func moveItem(at source: URL, to destination: URL) throws

    /// Checks whether a file exists at the provided path.
    func fileExists(atPath path: String) -> Bool
}
