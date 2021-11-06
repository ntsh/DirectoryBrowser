import SwiftUI

@main
struct SwiftuiappApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            HomeView(documentsStore: DocumentsStore(relativePath: "", sorting: .date(ascending: true))).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
