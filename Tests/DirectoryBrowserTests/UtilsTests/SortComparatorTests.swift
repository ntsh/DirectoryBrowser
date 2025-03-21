import XCTest
@testable import DirectoryManager

class SortComparatorTests: XCTestCase {

    private let document1 = Document(name: "AName", url: URL(string: "/")!, size: 1, modified: Date(timeIntervalSince1970: 0))
    private let document2 = Document(name: "BName", url: URL(string: "/")!, size: 2, modified: Date(timeIntervalSince1970: 10))

    func testDateAscendingComparator() {
        let sortOption = SortOption.date(ascending: true)
        let comparator = sortOption.sortingComparator()

        XCTAssertTrue(comparator(document1, document2))
    }

    func testDateDescendingComparator() {
        let sortOption = SortOption.date(ascending: false)
        let comparator = sortOption.sortingComparator()

        XCTAssertTrue(comparator(document2, document1))
    }

    func testNameAscendingComparator() {
        let sortOption = SortOption.name(ascending: true)
        let comparator = sortOption.sortingComparator()

        XCTAssertTrue(comparator(document1, document2))
    }

    func testNameDescendingComparator() {
        let sortOption = SortOption.name(ascending: false)
        let comparator = sortOption.sortingComparator()

        XCTAssertFalse(comparator(document1, document2))
    }
}
