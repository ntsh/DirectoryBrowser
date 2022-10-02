import SwiftUI

struct HomeView: View {
    @ObservedObject var documentsStore: DocumentsStore

    var body: some View {
        NavigationView {
            FolderView(documentsStore: documentsStore, title: "Documents")
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeView(documentsStore: DocumentsStore_Preview(relativePath: "/", sorting: .date(ascending: true)))
                .preferredColorScheme(.light)

            HomeView(documentsStore: DocumentsStore_Preview(relativePath: "/", sorting: .date(ascending: true)))
                .preferredColorScheme(.dark)
        }
    }
}
