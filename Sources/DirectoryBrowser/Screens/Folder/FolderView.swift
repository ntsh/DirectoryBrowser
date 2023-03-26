import SwiftUI

public struct FolderView: View {
    @State var isPresentedPicker = false
    @State var isPresentedPhotoPicker = false
    @State var isInputingNewFolderName = false
    @State var isInputingRenameDocName = false
    @State var documentToRename: Document?
    @State var documentNameErrorMessage: String?

    @ObservedObject var documentsStore: DocumentsStore
    var title: String

    var listSectionHeader: some View {
        HStack {
            if isInputingNewFolderName {
                DocumentNameInputView(errorMessage: $documentNameErrorMessage, heading: "Enter Folder Name") {
                    finishEnteringDocName()
                } setName: { (name) in
                    createFolder(name: name)
                }
            } else if isInputingRenameDocName {
                DocumentNameInputView(errorMessage: $documentNameErrorMessage, heading: "Enter new name") {
                    finishEnteringDocName()
                } setName: { (name) in
                    renameDocument(name: name)
                }
            } else {
                Text("All").background(Color.clear)
            }
        }
    }

    fileprivate func sortByDateButton() -> some View {
        let sortImage: String = documentsStore.sorting.dateButtonIcon()
        return Label("Sort by date", systemImage: sortImage)
    }

    fileprivate func sortByNameButton() -> some View {
        let sortImage: String =  documentsStore.sorting.nameButtonIcon()
        return Label("Sort by name", systemImage: sortImage)
    }

    var actionButtons: some View {
        HStack {
            Menu {
                Button(action: {
                    withAnimation {
                        documentsStore.setSorting(documentsStore.sorting.toggleToDateSortOption())
                    }
                }) {
                    sortByDateButton()
                }
                Button(action: {
                    withAnimation {
                        documentsStore.setSorting(documentsStore.sorting.toggleToNameSortOption())
                    }
                }) {
                    sortByNameButton()
                }
            } label: {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            Menu {
                Button(action: didClickAddButton) {
                    Label("Import from Files", systemImage: "arrow.up.doc.fill")
                }
                Button(action: { }) {
                    Label("Scan", systemImage: "doc.text.fill.viewfinder")
                }
                Button(action: didClickImportPhoto) {
                    Label("Import Photo", systemImage: "photo.fill.on.rectangle.fill")
                }
                Button(action: didClickCreateFolder) {
                    Label("Create folder", systemImage: "plus.rectangle.fill.on.folder.fill")
                }
            } label: {
                Image(systemName: "doc.fill.badge.plus")
                    .font(.title2)
                    .help(Text("Add documents"))
            }
        }
    }

    var emptyFolderView: some View {
        VStack {
            Text("Folder is empty")
                .multilineTextAlignment(.center)
                .padding()
        }
    }

    public init(documentsStore: DocumentsStore, title: String) {
        self.documentsStore = documentsStore
        self.title = title
    }

    public var body: some View {
        ZStack {
            List() {
                Section(header: listSectionHeader) {
                    ForEach(documentsStore.documents) { document in
                        NavigationLink(destination: navigationDestination(for: document)) {
                            DocumentRow(document: document)
                                .padding(.vertical)
                                .contextMenu {
                                    Button(action: { deleteDocument(document) }) {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    Button(action: { editDocumentName(document)}) {
                                        Label("Rename", systemImage: "pencil")
                                    }
                                    Button(action: {}) {
                                        Label("Move", systemImage: "folder.badge.gear")
                                    }
                                    Button(action: {}) {
                                        Label("Share", systemImage: "square.and.arrow.up")
                                    }
                                }
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .listStyle(InsetListStyle())
            .background(Color.clear)
            .navigationBarItems(trailing: actionButtons)
            .navigationTitle(title)
            .sheet(isPresented:  $isPresentedPicker, onDismiss: dismissPicker) {
                DocumentPicker(documentsStore: documentsStore) {
                    NSLog("Docupicker callback")
                }
            }
            .sheet(isPresented:  $isPresentedPhotoPicker, onDismiss: dismissPicker) {
                PhotoPicker(documentsStore: documentsStore) {
                    NSLog("Imagepicker callback")
                }
            }

            if (documentsStore.documents.isEmpty) {
                emptyFolderView
            }
        }.onAppear {
            documentsStore.loadDocuments()
        }
    }

    private func navigationDestination(for document: Document) -> AnyView {
        if document.isDirectory {
            let relativePath = documentsStore.relativePath(for: document)
            return AnyView(FolderView(documentsStore: DocumentsStore(root: documentsStore.docDirectory, relativePath: relativePath, sorting: documentsStore.sorting), title: document.name))
        } else {
            return AnyView(DocumentDetails(document: document))
        }
    }

    func didClickAddButton()  {
        NSLog("Did click add button")
        isPresentedPicker = true
    }

    func didClickImportPhoto() {
        isPresentedPhotoPicker = true
    }

    func dismissPicker() {
        isPresentedPicker = false
        isPresentedPhotoPicker = false
    }

    func didClickCreateFolder() {
        NSLog("Did click create folder")
        withAnimation {
            isInputingNewFolderName = true
        }
    }

    func createFolder(name: String) {
        NSLog("create folder \(name)")
        do {
            try documentsStore.createFolder(name)
            finishEnteringDocName()
        } catch DocumentsStoreError.fileExists {
            withAnimation {
                documentNameErrorMessage = "Folder already exists"
            }
        } catch {
            documentNameErrorMessage = "Unexpected error"
        }
    }

    fileprivate func finishEnteringDocName() {
        withAnimation {
            isInputingNewFolderName = false
            isInputingRenameDocName = false
            documentNameErrorMessage = nil
        }
    }

    private func deleteItems(offsets: IndexSet) {
        offsets
            .map { documentsStore.documents[$0] }
            .forEach { deleteDocument($0) }
    }

    private func deleteDocument(_ document: Document) {
        withAnimation {
            documentsStore.delete(document)
        }
    }

    private func editDocumentName(_ document: Document) {
        withAnimation {
            isInputingRenameDocName = true
            documentToRename = document
        }
    }

    private func renameDocument(name: String) {
        guard let documentToRename = documentToRename else { return }
        do {
            try documentsStore.rename(document: documentToRename, newName: name)
            finishEnteringDocName()
        } catch DocumentsStoreError.fileExists {
            withAnimation {
                documentNameErrorMessage = "Document already exists"
            }
        } catch {
            documentNameErrorMessage = "Unexpected error"
        }
    }
}

struct FolderView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FolderView(documentsStore: DocumentsStore_Preview(root: URL.temporaryDirectory, relativePath: "/", sorting: .date(ascending: true)), title: "Docs")
        }
    }
}
