import SwiftUI

@main
struct SwiftuiappApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
//            ContentView()
//                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)

//                .environment(\.managedObjectContext, persistenceController.container.viewContext)

            //  HomeView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            HomeView(documentsStore: DocumentsStore(relativePath: "", sorting: .date(ascending: true))).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)

        }
    }
}
