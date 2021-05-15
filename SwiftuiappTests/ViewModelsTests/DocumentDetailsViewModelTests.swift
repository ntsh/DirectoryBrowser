import XCTest
@testable import Swiftuiapp

class DocumentDetailsViewModelTests: XCTestCase {

    private var document = Document(id: UUID(),
                                    name: "Test.pdf",
                                    url: URL(fileURLWithPath: "/doc/Test.pdf"),
                                    size: NSNumber(integerLiteral: 1000),
                                    created: Date(timeIntervalSince1970: 0),
                                    modified: Date(timeIntervalSince1970: 1000),
                                    isDirectory: false)

    private var viewModel: DocumentDetailsViewModel!

    override func setUpWithError() throws {
        viewModel = DocumentDetailsViewModel(document: document)
    }

    func testDocumentName() {
        XCTAssertEqual(viewModel.documentName, "Test.pdf")
    }

    func testDocumentUrl() {
        XCTAssertEqual(viewModel.documentUrl, URL(fileURLWithPath: "/doc/Test.pdf"))
    }

    func testDocumentSize() {
        XCTAssertEqual(viewModel.documentSize, "1 KB")
    }

    func testDocumentCreated() {
        XCTAssertEqual(viewModel.documentCreated, "1/1/70, 1:00 AM")
    }

    func testDocumentModified() {
        XCTAssertEqual(viewModel.documentModified, "1/1/70, 1:16 AM")
    }

    func testDocumentCreatedIsNil() {
        document.created = nil
        viewModel = DocumentDetailsViewModel(document: document)
        XCTAssertNil(viewModel.documentCreated)
    }

    func testDocumentModifiedIsNil() {
        document.modified = nil
        viewModel = DocumentDetailsViewModel(document: document)
        XCTAssertNil(viewModel.documentModified)
    }

    func testShowPreview() {
        viewModel.showPreview()
        XCTAssertTrue(viewModel.showingPreview)
    }

    func testHidePreview() {
        viewModel.showingPreview = false
        XCTAssertFalse(viewModel.showingPreview)
    }
}
