import Foundation

public struct Document: Identifiable, Hashable {
    public var id = UUID()

    public var name: String
    public var url: URL
    public var size: NSNumber
    public var created: Date?
    public var modified: Date?

    public var isDirectory: Bool = false
}

public extension Document {
    var formattedSize: String {
        Int(truncating: size).formatted(ByteCountFormatStyle())
    }
}

extension Document: Equatable {
    public static func == (lhs: Document, rhs: Document) -> Bool {
        lhs.id == rhs.id
    }
}
