import XCTest
import SwiftUI
@testable import DirectoryBrowser

final class ConfirmDeleteEnvironmentTests: XCTestCase {
    func testDefaultValue() {
        let values = EnvironmentValues()
        XCTAssertFalse(values.confirmDelete)
    }

    func testSetValue() {
        var values = EnvironmentValues()
        values.confirmDelete = true
        XCTAssertTrue(values.confirmDelete)
    }
}
