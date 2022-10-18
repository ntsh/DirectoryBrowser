import XCTest
@testable import DirectoryBrowser
import SwiftUI

@MainActor
class DocumentsStoreTests: XCTestCase {

    private var documentsStore: DocumentsStore!
    private var mockFileManager: TempFileManager!

    private class TempFileManager: DocumentManager {

        typealias DocumentInfo = (name: String, date: Date)

        private var docs: [DocumentInfo]

        init(docs: [DocumentInfo]) {
            self.docs = docs
        }

        override func documentDirectory() -> URL? {
           return FileManager.default.temporaryDirectory
        }

        override func contentsOfDirectory(at url: URL) throws -> [URL] {
            let urls: [URL] = docs.compactMap { (name: String, date: Date) in
                var url = URL(fileURLWithPath: name, isDirectory: false, relativeTo: documentDirectory()!)

                var resourceValues = URLResourceValues()
                resourceValues.name = name
                resourceValues.contentModificationDate = date

                FileManager.default.createFile(atPath: url.path, contents: Data(base64Encoded: "test"), attributes: [:])
                try! url.setResourceValues(resourceValues)

                return url
            }

            return urls
        }
    }

    override func setUpWithError() throws {
        let doc1 = (name: "test.pdf", date: Date(timeIntervalSince1970: 100))
        let doc2 = (name: "OtherTest.jpeg", date: Date(timeIntervalSince1970: 10))
        mockFileManager = TempFileManager(docs: [doc1, doc2])

        documentsStore = DocumentsStore(relativePath: "/", sorting: .date(ascending: false), documentsSource: mockFileManager)
        documentsStore.loadDocuments()
    }

    override func tearDownWithError() throws {
        let urls = try FileManager.default.contentsOfDirectory(at: mockFileManager.documentDirectory()!, includingPropertiesForKeys: [], options: [])
        urls.forEach { url in
            try? FileManager.default.removeItem(at: url)
        }

        documentsStore = nil
    }

    func testDefaultSort() {
        let documents = documentsStore.documents
        XCTAssertEqual(documents.first?.name, "test.pdf")
    }

    func testChangeSort() {
        documentsStore.setSorting(.name(ascending: false))
        var documents = documentsStore.documents
        XCTAssertEqual(documents.first?.name, "test.pdf")

        documentsStore.setSorting(.name(ascending: true))
        documents = documentsStore.documents
        XCTAssertEqual(documents.first?.name, "OtherTest.jpeg")
    }

    func testImportDocument() {
        let docToImport = documentsStore.documents.first!
        let urlToImport = docToImport.url

        let folderUrl = mockFileManager.documentDirectory()?.appendingPathComponent("testFolder", isDirectory: true)
        try? mockFileManager.createDirectory(at: folderUrl!)

        let docStore = DocumentsStore(relativePath: "/testFolder", sorting: SortOption.date(ascending: false), documentsSource: mockFileManager)
        docStore.importFile(from: urlToImport)

        let importedDocument = docStore.documents.first { doc in
            doc.name == "test.pdf"
        }
        XCTAssertNotNil(importedDocument)

        // Import same file again to test if a copy is made
        docStore.importFile(from: urlToImport)
        let importedDocumentCopy = docStore.documents.first { doc in
            doc.name == "test (1).pdf"
        }
        XCTAssertNotNil(importedDocumentCopy)
    }

    func testDeleteDocument() {
        let documentsOriginal = documentsStore.documents
        let firstDocument = documentsOriginal.first

        documentsStore.delete(firstDocument!)

        let documentsNew = documentsStore.documents
        let isPresent = documentsNew.contains(where: { document in
            document.id == firstDocument!.id
        })
        XCTAssertFalse(isPresent)
    }

    func testCreateFolder() {
        try? documentsStore.createFolder("TestFolder")
        let documents = documentsStore.documents

        let folder = documents.first { document in
            document.name == "TestFolder"
        }

        XCTAssertEqual(folder!.name, "TestFolder")
        XCTAssertTrue(folder!.isDirectory)
    }

    func testCreateFolderWithConflictingName() {
        try? documentsStore.createFolder("TestFolder")

        XCTAssertThrowsError(try documentsStore.createFolder("TestFolder")) { error in
            XCTAssertEqual(error as! DocumentsStoreError, .fileExists)
        }
    }

    func testRenameDocument() {
        let documentsOriginal = documentsStore.documents
        let firstDocument = documentsOriginal.first

        try? documentsStore.rename(document: firstDocument!, newName: "newName.pdf")

        let documentsNew = documentsStore.documents
        let updatedDocument = documentsNew.first(where: { document in
            document.id == firstDocument!.id
        })
        XCTAssertEqual(updatedDocument?.name, "newName.pdf")
    }

    func testRenameDocumentWithConflictingName() {
        let documentsOriginal = documentsStore.documents
        let firstDocument = documentsOriginal.first

        XCTAssertThrowsError(try documentsStore.rename(document: firstDocument!, newName: "OtherTest.jpeg")) { error in
            XCTAssertEqual(error as! DocumentsStoreError, .fileExists)
        }
    }

    func testRelativePath() {
        let documentsOriginal = documentsStore.documents
        let firstDocument = documentsOriginal.first!

        let relativePath = documentsStore.relativePath(for: firstDocument)
        XCTAssertEqual(relativePath, "/test.pdf")
    }
}
