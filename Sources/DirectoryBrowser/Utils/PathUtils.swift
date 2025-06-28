import Foundation

public func humanReadablePath(for url: URL, root: URL) -> String {
    var relative = url.path.replacingOccurrences(of: root.path, with: "")
    if relative.hasPrefix("/") { relative.removeFirst() }
    if relative.isEmpty { return root.lastPathComponent }
    return root.lastPathComponent + "/" + relative
}

public func relativePath(for url: URL, root: URL) -> String {
    var relative = url.path.replacingOccurrences(of: root.path, with: "")
    if relative.hasPrefix("/") { relative.removeFirst() }
    return "/" + relative
}
