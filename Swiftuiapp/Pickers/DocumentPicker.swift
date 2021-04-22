import Foundation
import SwiftUI

struct DocumentPicker: UIViewControllerRepresentable {

    typealias UIViewControllerType = UIDocumentPickerViewController

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
            let docDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

            var suitableUrl = docDirectory!.appendingPathComponent(url.lastPathComponent)

            var retry = true
            var retryCount = 1
            while retry {
                retry = false

                do {
                    try FileManager.default.copyItem(at: url, to: suitableUrl)
                } catch CocoaError.fileWriteFileExists {
                    retry = true

                    // append (1) to file name
                    let fileExtension = url.pathExtension
                    let fileNameWithoutExtension = url.deletingPathExtension().lastPathComponent
                    let fileNameWithCountSuffix = fileNameWithoutExtension.appending(" (\(retryCount))")
                    suitableUrl = docDirectory!.appendingPathComponent(fileNameWithCountSuffix).appendingPathExtension(fileExtension)

                    retryCount += 1

                    NSLog("Retry *** suitableName = \(suitableUrl.lastPathComponent)")
                } catch let error as NSError {
                    NSLog("Error importing file: \(error)")
                }
            }
        }
    }
}
