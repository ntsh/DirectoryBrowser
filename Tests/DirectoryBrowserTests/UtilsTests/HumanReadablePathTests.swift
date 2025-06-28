import XCTest
@testable import DirectoryBrowser

final class HumanReadablePathTests: XCTestCase {
    func testHumanReadablePath() {
        let root = URL(fileURLWithPath: "/var/mobile/Documents", isDirectory: true)
        let file = root.appendingPathComponent("Foo/bar.txt")
        let path = humanReadablePath(for: file, root: root)
        XCTAssertEqual(path, "Documents/Foo/bar.txt")
    }
}
