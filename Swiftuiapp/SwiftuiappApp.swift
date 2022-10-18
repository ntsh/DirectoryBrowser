import SwiftUI
import DirectoryBrowser

@main
struct SwiftuiappApp: App {
    var body: some Scene {
        WindowGroup {
            //DirectoryBrowser(documentsStore: DocumentsStore())
            HomwView()
        }
    }
}

struct HomwView: View {
    @State var browse = false
    var body: some View {
        Button("Browse") {
            browse = true
        }
        .sheet(isPresented: $browse) {
            DirectoryBrowser(documentsStore: DocumentsStore())
        }
    }
}
