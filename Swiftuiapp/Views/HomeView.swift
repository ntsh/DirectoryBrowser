import SwiftUI

struct HomeView: View {
    @State private var isPresentedPicker = false

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    @ObservedObject var documentsStore: DocumentsStore

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(documentsStore.documents) { document in
                        NavigationLink(destination: DocumentDetails(document: document)) {
                            DocumentRow(document: document)
                                .padding(.vertical)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .listStyle(GroupedListStyle())

                Button(action: didClickAddButton, label: {
                    Text("Add")
                })
            }
            .navigationBarItems(trailing: HStack {
                Button(action: {}) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.title)
                }.foregroundColor(.blue)
                Button(action: didClickAddButton) {
                    Image(systemName: "plus.square.fill")
                        .font(.largeTitle)
                }.foregroundColor(.blue)
            })
            .navigationTitle("All Documents")
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
        HomeView(documentsStore: DocumentsStore_Preview())
            .preferredColorScheme(.dark)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
