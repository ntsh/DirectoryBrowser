import SwiftUI

struct FolderView: View {
    @State var isPresentedPicker = false
    @State var isInputingName: Bool = false

    @ObservedObject var documentsStore: DocumentsStore
    var title: String

    var listSectionHeader: some View {
        HStack {
            if isInputingName {
                DocumentNameInputView {
                    withAnimation {
                        isInputingName = false
                    }
                } setName: { (name) in
                    createFolder(name: name)
                    withAnimation {
                        isInputingName = false
                    }
                }
            } else {
                Text("All").background(Color.clear)
            }
        }
    }

    var actionButtons: some View {
        HStack {
            Button(action: {}) {
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

    var body: some View {
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
        .navigationBarItems(trailing: actionButtons)
        .navigationTitle(title)
        .sheet(isPresented:  $isPresentedPicker, onDismiss: dismissPicker) {
            DocumentPicker(documentsStore: documentsStore) {
                NSLog("Docupicker callback")
                documentsStore.reload()
            }
        }
    }

    private func navigationDestination(for document: Document) -> AnyView {
        if document.isDirectory {
            let relativePath = documentsStore.relativePath(for: document)
            return AnyView(FolderView(documentsStore: DocumentsStore(relativePath: relativePath), title: document.name))
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
        documentsStore.createFolder(name)
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
            FolderView(isInputingName: true, documentsStore: DocumentsStore_Preview(relativePath: "/"), title: "Docs")
        }
    }
}
