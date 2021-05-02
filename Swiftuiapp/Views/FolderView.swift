import SwiftUI

enum SortOption: Equatable {
    case date(ascending: Bool)
    case name(ascending: Bool)
}

struct FolderView: View {
    @State var isPresentedPicker = false
    @State var isInputingName = false
    @State var documentNameErrorMessage: String?

    @ObservedObject var documentsStore: DocumentsStore
    var title: String

    var listSectionHeader: some View {
        HStack {
            if isInputingName {
                DocumentNameInputView(errorMessage: $documentNameErrorMessage, heading: "Enter Folder Name") {
                    finishEnteringDocName()
                } setName: { (name) in
                    createFolder(name: name)
                }
            } else {
                Text("All").background(Color.clear)
            }
        }
    }

    fileprivate func sortByDateButton() -> some View {
        var sortImage: String = ""

        switch documentsStore.sorting {
        case .date(ascending: true):
            sortImage = "arrow.up"
        case .date(ascending: false):
            sortImage = "arrow.down"
        case .name(ascending: _):
            sortImage = ""
        }

        return Label("Sort by date", systemImage: sortImage)
    }

    fileprivate func sortByNameButton() -> some View {
        var sortImage: String = ""

        switch documentsStore.sorting {
        case .name(ascending: true):
            sortImage = "arrow.up"
        case .name(ascending: false):
            sortImage = "arrow.down"
        case .date(ascending: _):
            sortImage = ""
        }

        return Label("Sort by name", systemImage: sortImage)
    }

    var actionButtons: some View {
        HStack {
            Menu {
                Button(action: {
                    withAnimation {
                        switch documentsStore.sorting {
                        case .date(ascending: let ascending):
                            documentsStore.sorting = .date(ascending: !ascending)
                        case .name(ascending: _):
                            documentsStore.sorting = .date(ascending: true)
                        }
                        documentsStore.setSorting(documentsStore.sorting)
                    }
                }) {
                    sortByDateButton()
                }
                Button(action: {
                    withAnimation {
                        switch documentsStore.sorting {
                        case .name(ascending: let ascending):
                            documentsStore.sorting = .name(ascending: !ascending)
                        case .date(ascending: _):
                            documentsStore.sorting = .name(ascending: true)
                        }
                        documentsStore.setSorting(documentsStore.sorting)
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
                Button(action: { }) {
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

    var body: some View {
        ZStack {
            List() {
                Section(header: listSectionHeader) {
                    ForEach(documentsStore.documents) { document in
                        NavigationLink(destination: navigationDestination(for: document)) {
                            DocumentRow(document: document)
                                .padding(.vertical)
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
                    documentsStore.reload()
                }
            }

            if (documentsStore.documents.isEmpty) {
                emptyFolderView
            }
        }
    }

    private func navigationDestination(for document: Document) -> AnyView {
        if document.isDirectory {
            let relativePath = documentsStore.relativePath(for: document)
            return AnyView(FolderView(documentsStore: DocumentsStore(relativePath: relativePath, sorting: documentsStore.sorting), title: document.name))
        } else {
            return AnyView(DocumentDetails(document: document))
        }
    }

    func didClickAddButton()  {
        NSLog("Did click add button")
        isPresentedPicker = true
    }

    func dismissPicker() {
        self.isPresentedPicker = false
    }

    func didClickCreateFolder() {
        NSLog("Did click create folder")
        withAnimation {
            isInputingName = true
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
            isInputingName = false
            documentNameErrorMessage = nil
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets
                .map { documentsStore.documents[$0] }
                .forEach { documentsStore.delete($0) }
        }
    }
}

struct FolderView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FolderView(isInputingName: true, documentsStore: DocumentsStore_Preview(relativePath: "/", sorting: .date(ascending: true)), title: "Docs")
        }
    }
}
