import SwiftUI
import PhotosUI
import Foundation

struct PhotoPicker: UIViewControllerRepresentable {

    typealias UIViewControllerType = PHPickerViewController

    var documentsStore: DocumentImporter
    var callback: () -> ()

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var pickerConfig = PHPickerConfiguration()
        pickerConfig.selectionLimit = 0
        pickerConfig.preferredAssetRepresentationMode = .current

        let picker = PHPickerViewController(configuration: pickerConfig)
        picker.delegate = context.coordinator

        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // Nothing to see here
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker

        init(_ parent: PhotoPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            results.forEach { pickerResult in
                importFile(from: pickerResult.itemProvider)
            }

            parent.callback()
        }

        fileprivate func importFile(from itemProvider: NSItemProvider) {
            var fileTypeIdentifier = UTType.image.identifier

            if itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                fileTypeIdentifier = UTType.movie.identifier
            }

            itemProvider.loadFileRepresentation(forTypeIdentifier: fileTypeIdentifier) { url, error in
                guard let url = url, error == nil else { return }
                self.importFile(from: url)
            }
        }

        private func importFile(from url: URL) {
            do {
                // Copy to a temp folder
                let tempDirectory = URL.temporaryDirectory.appendingPathComponent(UUID().uuidString)
                try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true, attributes: nil)
                let tempFileUrl = tempDirectory.appendingPathComponent(url.lastPathComponent)
                try FileManager.default.copyItem(at: url, to: tempFileUrl)
                Task {
                    await parent.documentsStore.importFile(from: tempFileUrl)
                    try? FileManager.default.removeItem(at: tempFileUrl)
                    try? FileManager.default.removeItem(at: tempDirectory)
                }
            } catch {
                print("PhotoPicker: Error copying to temp file: \(error)")
            }
        }
    }
}
