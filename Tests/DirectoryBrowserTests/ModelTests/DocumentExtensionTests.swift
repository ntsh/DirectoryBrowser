import XCTest
@testable import DirectoryManager

final class DocumentExtensionTests: XCTestCase {
    private var document = Document(
        id: UUID(),
        name: "Test.pdf",
        url: URL(fileURLWithPath: "/doc/Test.pdf"),
        size: NSNumber(integerLiteral: 1000),
        created: Date(timeIntervalSince1970: 0),
        modified: Date(timeIntervalSince1970: 1000),
        isDirectory: false
    )

    func testFormattedSize() throws {
        XCTAssertEqual(document.formattedSize, "1 kB")
    }
}
