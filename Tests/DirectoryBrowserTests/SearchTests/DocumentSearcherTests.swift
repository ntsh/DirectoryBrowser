import XCTest
@testable import DirectoryBrowser
import DirectoryManager

@MainActor
final class DocumentSearcherTests: XCTestCase {
    private var tempRoot: URL!

    override func setUpWithError() throws {
        tempRoot = URL.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempRoot)
        let fileURL = tempRoot.appendingPathComponent("TestFile.txt")
        FileManager.default.createFile(atPath: fileURL.path, contents: Data())
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: tempRoot)
    }

    func testSearchFindsFile() {
        let searcher = DocumentSearcher(roots: [tempRoot])
        searcher.search(query: "testfile")
        XCTAssertTrue(searcher.results.contains { $0.document.name == "TestFile.txt" })
    }
}
