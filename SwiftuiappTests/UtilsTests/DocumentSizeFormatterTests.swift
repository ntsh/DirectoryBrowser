import XCTest
@testable import Swiftuiapp

class DocumentSizeFormatterTests: XCTestCase {

    func testSizeFormatting() {
        let formattedSize = DocumentSizeFormatter.string(fromByteCount: 1000)
        XCTAssertEqual(formattedSize, "1 KB")
    }
}
