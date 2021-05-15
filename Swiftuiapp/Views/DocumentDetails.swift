import SwiftUI

struct DocumentDetails: View {
    @ObservedObject var viewModel: DocumentDetailsViewModel

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            List {
                ThumbnailView(url: viewModel.documentUrl)
                    .padding(.vertical)
                    .onTapGesture {
                        viewModel.showPreview()
                    }

                HStack {
                    Spacer()
                    Text(viewModel.documentName)
                        .multilineTextAlignment(.center)
                        .font(.headline)
                    Spacer()
                }

                DocumentAttributeRow(key: "Size", value: viewModel.documentSize)

                if let created = viewModel.documentCreated {
                    DocumentAttributeRow(key: "Created", value: created)
                }

                if let modified = viewModel.documentModified {
                    DocumentAttributeRow(key: "Modified", value: modified)
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .fullScreenCover(isPresented: $viewModel.showingPreview) {
            PreviewController(url: viewModel.documentUrl, isPresented: $viewModel.showingPreview)
        }
        .navigationBarItems(trailing: HStack {
            Button(action: { viewModel.showPreview() }) {
                Image(systemName: "play.fill")
                    .font(.largeTitle)
            }.foregroundColor(.blue)
        })
    }
}

struct DocumentDetails_Previews: PreviewProvider {
    static var previews: some View {
        DocumentDetails(viewModel: DocumentDetailsViewModel(document: DocumentsStore_Preview(relativePath: "/", sorting: .date(ascending: true)).documents[1]))
            .preferredColorScheme(.dark)
            .environment(\.sizeCategory, .large)
    }
}
