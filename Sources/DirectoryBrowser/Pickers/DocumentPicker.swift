import Foundation
import SwiftUI

struct DocumentPicker: UIViewControllerRepresentable {

    typealias UIViewControllerType = UIDocumentPickerViewController

    var documentsStore: DocumentsStore
    var callback: () -> ()

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.item, .archive], asCopy: true)
        picker.shouldShowFileExtensions = true
        picker.allowsMultipleSelection = true
        picker.delegate = context.coordinator
        
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // Nothing to do here for now
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker

        init(_ parent: DocumentPicker) {
            self.parent = parent
        }

        //MARK: UIDocumentPickerDelegate
        internal func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            NSLog("Document picker selected documents at \(urls)")
            urls.forEach { url in
                importFile(from: url)
            }

            parent.callback()
        }

        internal func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            NSLog("Document picker cancelled")
        }

        private func importFile(from url: URL) {
            parent.documentsStore.importFile(from: url)
        }
    }
}
