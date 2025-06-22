import Foundation

/// Representation of a file or folder used by `DocumentsStore`.
///
/// A `Document` exposes basic metadata describing the item such as its name,
/// size and important dates. It conforms to `Identifiable` and `Hashable` so it
/// can be displayed directly in SwiftUI views.
public struct Document: Identifiable, Hashable {
    public var id = UUID()

    /// Display name of the item.
    public var name: String

    /// File location on disk.
    public var url: URL

    /// File size in bytes.
    public var size: NSNumber

    /// Creation timestamp.
    public var created: Date?

    /// Last modification timestamp.
    public var modified: Date?

    /// Indicates whether the item represents a directory.
    public var isDirectory: Bool = false
}

public extension Document {
    /// Human readable size string using `ByteCountFormatStyle`.
    ///
    /// ```swift
    /// print(document.formattedSize)
    /// ```
    var formattedSize: String {
        Int(truncating: size).formatted(ByteCountFormatStyle())
    }
}

extension Document: Equatable {
    public static func == (lhs: Document, rhs: Document) -> Bool {
        lhs.id == rhs.id
    }
}
