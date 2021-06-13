import SwiftUI
import PhotosUI
import Foundation

struct PhotoPicker: UIViewControllerRepresentable {

    typealias UIViewControllerType = PHPickerViewController

    var documentsStore: DocumentsStore
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
            let temporaryDirectory = FileManager.default.temporaryDirectory

            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    if let image = image as? UIImage {
                        // save image to temp location and pass the url to documentsstore
                        let name = itemProvider.suggestedName

                        let tempUrl = temporaryDirectory.appendingPathComponent(name ?? UUID().uuidString).appendingPathExtension("png")
                        if let data = image.pngData() {
                            FileManager.default.createFile(atPath: tempUrl.relativePath, contents: data, attributes: nil)
                            self.importFile(from: tempUrl)
                            try? FileManager.default.removeItem(at: tempUrl)
                        }
                    }
                }
            } else { // video
                itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                    if let url = url {
                        self.importFile(from: url)
                    }
                }
            }
        }

        private func importFile(from url: URL) {
            parent.documentsStore.importFile(from: url)
        }
    }
}
