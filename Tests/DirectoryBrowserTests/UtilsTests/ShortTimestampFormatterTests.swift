import XCTest
@testable import DirectoryBrowser

class ShortTimestampFormatterTests: XCTestCase {

    func testShortTimeStampIsCreated() throws {
        let date = Date(timeIntervalSince1970: 0)
        let formattedDate = ShortTimestampFormatter.string(from: date)
        XCTAssertEqual(formattedDate, "1/1/70, 1:00 AM")
    }
}
