import XCTest
@testable import DirectoryBrowser

class ShortTimestampFormatterTests: XCTestCase {

    func testShortTimeStampIsCreated() throws {
        let date = Date(timeIntervalSince1970: 0)
        let formattedDate = ShortTimestampFormatter.string(from: date)
        XCTAssertEqual(formattedDate, "01/01/1970, 1:00 AM")
    }
}
