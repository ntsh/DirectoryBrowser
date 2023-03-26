import SwiftUI
import DirectoryBrowser

struct ContentView: View {
    @State var browse = false

    var body: some View {
        Button("Browse") {
            browse = true
        }
        .sheet(isPresented: $browse) {
            DirectoryBrowser(documentsStore: DocumentsStore(root: .temporaryDirectory))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
