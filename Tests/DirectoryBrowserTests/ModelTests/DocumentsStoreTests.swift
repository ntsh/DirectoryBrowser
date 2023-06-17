import XCTest
@testable import DirectoryManager
import SwiftUI

@MainActor
class DocumentsStoreTests: XCTestCase {
    private var documentsStore: DocumentsStore!

    private let doc1 = (name: "test.pdf", date: Date(timeIntervalSince1970: 100))
    private let doc2 = (name: "OtherTest.jpeg", date: Date(timeIntervalSince1970: 10))

    override func setUpWithError() throws {
        let urls = try FileManager.default.contentsOfDirectory(at: .temporaryDirectory, includingPropertiesForKeys: [], options: [])
        urls.forEach { url in
            try? FileManager.default.removeItem(at: url)
        }
        [doc1, doc2].forEach { (name: String, date: Date) in
            var url = URL(fileURLWithPath: name, isDirectory: false, relativeTo: .temporaryDirectory)

            var resourceValues = URLResourceValues()
            resourceValues.name = name
            resourceValues.contentModificationDate = date

            FileManager.default.createFile(atPath: url.path, contents: Data(base64Encoded: "test"), attributes: [:])
            try! url.setResourceValues(resourceValues)
        }

        documentsStore = DocumentsStore(
            root: .temporaryDirectory,
            relativePath: "",
            sorting: .date(ascending: false),
            documentsSource: FileManager.default
        )
        documentsStore.loadDocuments()
    }

    override func tearDownWithError() throws {
        let urls = try FileManager.default.contentsOfDirectory(at: .temporaryDirectory, includingPropertiesForKeys: [], options: [])
        urls.forEach { url in
            try? FileManager.default.removeItem(at: url)
        }

        documentsStore = nil
    }

    func testDefaultSort() {
        let documents = documentsStore.documents
        XCTAssertEqual(documents.first?.name, "test.pdf")
    }

    func testChangeSort() async {
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

        let folderUrl = URL.temporaryDirectory.appendingPathComponent("testFolder", isDirectory: true)
        try? FileManager.default.createDirectory(at: folderUrl)

        let docStore = DocumentsStore(root: .temporaryDirectory, relativePath: "testFolder", sorting: SortOption.date(ascending: false), documentsSource: FileManager.default)
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

    func testCreateNewFolder() throws {
        try documentsStore.createNewFolder()

        let documentsNew = documentsStore.documents
        let isPresent = documentsNew.contains(where: { document in
            document.name == "New Folder"
        })
        XCTAssertTrue(isPresent)
    }

    func testCreateNewFolderDuplicateName() throws {
        try documentsStore.createNewFolder()
        try documentsStore.createNewFolder()

        let documentsNew = documentsStore.documents
        let isPresent = documentsNew.contains {
            $0.name == "New Folder (1)"
        }
        XCTAssertTrue(isPresent)
    }

    func testCreateFolder() {
        _ = try? documentsStore.createFolder("TestFolder")
        let documents = documentsStore.documents

        let folder = documents.first {
            $0.name == "TestFolder"
        }

        XCTAssertEqual(folder!.name, "TestFolder")
        XCTAssertTrue(folder!.isDirectory)
    }

    func testCreateFolderWithConflictingName() {
        _ = try? documentsStore.createFolder("TestFolder")

        XCTAssertThrowsError(try documentsStore.createFolder("TestFolder")) { error in
            XCTAssertEqual(error as! DocumentsStoreError, .fileExists)
        }
    }

    func testRenameDocument() {
        let documentsOriginal = documentsStore.documents
        let firstDocument = documentsOriginal.first

        _ = try? documentsStore.rename(document: firstDocument!, newName: "newName.pdf")

        let documentsNew = documentsStore.documents
        let updatedDocument = documentsNew.first(where: { document in
            document.id == firstDocument!.id
        })
        XCTAssertEqual(updatedDocument?.name, "newName.pdf")
    }

    func testRenameDocumentTwice() {
        let documentsOriginal = documentsStore.documents
        let firstDocument = documentsOriginal.first

        let doc1 = try? documentsStore.rename(document: firstDocument!, newName: "newName.pdf")
        _ = try? documentsStore.rename(document: doc1!, newName: "newName2.pdf")

        let documentsNew = documentsStore.documents
        let updatedDocument = documentsNew.first {
            $0.id == firstDocument!.id
        }
        XCTAssertEqual(updatedDocument?.name, "newName2.pdf")
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
