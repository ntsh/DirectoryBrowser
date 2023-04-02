import SwiftUI

public struct FolderView: View {
    @State var isPresentedPicker = false
    @State var isPresentedPhotoPicker = false
    @State var listProxy: ScrollViewProxy? = nil
    @State var lastCreatedNewFolder: Document?

    @ObservedObject var documentsStore: DocumentsStore
    var title: String

    @ViewBuilder
    var listSectionHeader: some View {
        Text("All")
            .background(Color.clear)
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
                Button(action: { isPresentedPicker = true }) {
                    Label("Import from Files", systemImage: "arrow.up.doc.fill")
                }
                Button(action: { }) {
                    Label("Scan", systemImage: "doc.text.fill.viewfinder")
                }
                Button(action: { isPresentedPhotoPicker = true }) {
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
            ScrollViewReader { scrollViewProxy in
                List {
                    Section(header: listSectionHeader) {
                        ForEach($documentsStore.documents) { document in
                            NavigationLink(destination: navigationDestination(for: document.wrappedValue)) {
                                DocumentRow(
                                    document: document,
                                    shouldEdit: (document.id == lastCreatedNewFolder?.id),
                                    documentsStore: documentsStore
                                )
                                .padding(.vertical)
                                .id(document.id)
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                }
                .listStyle(InsetListStyle())
                .onAppear {
                    listProxy = scrollViewProxy
                }
                .refreshable {
                    documentsStore.reload()
                }
            }
            .background(Color.clear)
            .navigationBarItems(trailing: actionButtons)
            .navigationTitle(title)
            .sheet(isPresented:  $isPresentedPicker) {
                DocumentPicker(documentsStore: documentsStore) {
                    NSLog("Docupicker callback")
                }
            }
            .sheet(isPresented:  $isPresentedPhotoPicker) {
                PhotoPicker(documentsStore: documentsStore) {
                    NSLog("Imagepicker callback")
                }
            }

            if (documentsStore.documents.isEmpty) {
                emptyFolderView
            }
        }
        .task {
            documentsStore.loadDocuments()
        }
    }

    @ViewBuilder
    private func navigationDestination(for document: Document) -> some View {
        if document.isDirectory {
            let relativePath = documentsStore.relativePath(for: document)
            FolderView(
                documentsStore: DocumentsStore(
                    root: documentsStore.docDirectory,
                    relativePath: relativePath,
                    sorting: documentsStore.sorting
                ),
                title: document.name
            )
        } else {
            DocumentDetails(document: document)
        }
    }

    func didClickCreateFolder() {
        NSLog("Did click create folder")
        do {
            lastCreatedNewFolder = try documentsStore.createNewFolder()
            if let lastCreatedNewFolder {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
                    withAnimation {
                        listProxy?.scrollTo(lastCreatedNewFolder.id, anchor: .top)
                    }
                }
            }
        } catch {
            // TODO: Show alert?
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
}

import FilePreviews

struct FolderView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FolderView(documentsStore: DocumentsStore_Preview(root: URL.temporaryDirectory, relativePath: "/", sorting: .date(ascending: true)), title: "Docs")
                .environmentObject(Thumbnailer())
        }
    }
}
