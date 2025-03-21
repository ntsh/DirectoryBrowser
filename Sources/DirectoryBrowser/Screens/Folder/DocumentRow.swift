import DirectoryManager
import FilePreviews
import SwiftUI

struct DocumentRow: View {
    @Binding var document: Document
    var shouldEdit: Bool = false
    @ObservedObject var documentsStore: DocumentsStore

    @State private var isEditing = false
    @FocusState private var nameEditIsFocused: Bool
    @State private var documentNameErrorMessage: String?

    var body: some View {
        HStack (alignment: .center, spacing: 16) {
            ThumbnailView(url: document.url)
                .frame(width: 60, height: 60, alignment: .center)
                .clipped()
                .cornerRadius(8)

            if isEditing {
                editDocumentView
            } else {
                documentSummaryView
            }
        }
        .contextMenu {
            Button(action: deleteDocument) {
                Label("Delete", systemImage: "trash")
            }
            Button(action: {
                isEditing = true
            }) {
                Label("Rename", systemImage: "pencil")
            }
            Button(action: {}) {
                Label("Move", systemImage: "folder.badge.gear")
            }
            Button(action: {}) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
        }
        .onChange(of: isEditing) {
            nameEditIsFocused = $0
        }
        .onAppear {
            isEditing = shouldEdit
        }
    }

    private var editDocumentView: some View {
        HStack {
            VStack(alignment: .leading) {
                TextField("Name", text: $document.name, prompt: nil)
                    .focused($nameEditIsFocused)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit(renameDocument)
                
                if let errMsg = documentNameErrorMessage {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.circle.fill")
                        Text(errMsg).font(.callout)
                    }
                    .foregroundColor(.red)
                    .padding(.bottom)
                }
            }
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundColor(.green)
                .padding()
                .onTapGesture(perform: renameDocument)
        }
    }

    private var documentSummaryView: some View {
        VStack(alignment: .leading, spacing: 12 ) {
            Text(document.name)
                .font(.headline)
                .lineLimit(2)
                .allowsTightening(true)

            if let modified = document.modified {
                Text(modified.formatted())
                    .font(.subheadline)
                    .lineLimit(1)
                    .allowsTightening(true)
                    .minimumScaleFactor(0.5)
            }
        }
    }

    private func renameDocument() {
        withAnimation {
            documentNameErrorMessage = nil
            do {
                try documentsStore.rename(document: document, newName: document.name)
                isEditing = false
            } catch DocumentsStoreError.fileExists {
                withAnimation {
                    documentNameErrorMessage = "Document already exists"
                }
            } catch {
                print("Unexpected error during rename: \(error)")
                documentNameErrorMessage = "Unexpected error"
            }
        }
    }

    private func deleteDocument() {
        withAnimation {
            documentsStore.delete(document)
        }
    }
}

struct DocumentRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DocumentRow(
                document: .constant(DocumentsStore_Preview(
                    root: URL.temporaryDirectory,
                    relativePath: "/", sorting: .date(ascending: true)
                ).documents[1]),
                documentsStore: DocumentsStore_Preview(root: URL.temporaryDirectory)
            )
            .environment(\.sizeCategory, .large)
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
            .environmentObject(Thumbnailer())
        }
    }
}
