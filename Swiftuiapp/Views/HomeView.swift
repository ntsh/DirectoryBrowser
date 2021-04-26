import SwiftUI

struct HomeView: View {
    @State var isPresentedPicker = false
    @State var isInputingName: Bool = false

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    @ObservedObject var documentsStore: DocumentsStore

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

    var body: some View {
        NavigationView {
            List() {
                Section(header: listSectionHeader) {
                    ForEach(documentsStore.documents) { document in
                        NavigationLink(destination: DocumentDetails(document: document)) {
                            DocumentRow(document: document)
                                .padding(.vertical)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .listStyle(InsetListStyle())
            .navigationBarItems(trailing: HStack {
                Button(action: {}) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.title)
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
                    Image(systemName: "plus.square.fill")
                        .font(.title)
                        .help(Text("Add documents"))
                }
            })
            .navigationTitle("Documents")
        }
        .sheet(isPresented:  $isPresentedPicker, onDismiss: dismissPicker) {
            DocumentPicker {
                NSLog("Docupicker callback")
                documentsStore.reload()
            }
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

    func didClickBrowseButton() {
        NSLog("didClickBrowseButton")
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeView(isInputingName: true, documentsStore: DocumentsStore_Preview())
                .preferredColorScheme(.light)
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)

            HomeView(isInputingName: true, documentsStore: DocumentsStore_Preview())
                .preferredColorScheme(.dark)
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }

    }
}
