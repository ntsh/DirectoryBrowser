#if os(iOS)
import SwiftUI
import VisionKit

struct DocumentScanner: UIViewControllerRepresentable {
    typealias UIViewControllerType = VNDocumentCameraViewController

    var documentsStore: DocumentImporter
    var callback: () -> ()

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let controller = VNDocumentCameraViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let parent: DocumentScanner

        init(_ parent: DocumentScanner) {
            self.parent = parent
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            controller.dismiss(animated: true)
            parent.callback()
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            print("DocumentScanner failed with error: \(error)")
            controller.dismiss(animated: true)
            parent.callback()
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            controller.dismiss(animated: true)

            if let pdfURL = scan.exportPDF() {
                Task { @MainActor in
                    await parent.documentsStore.importFile(from: pdfURL)
                    try? FileManager.default.removeItem(at: pdfURL)
                }
            }

            parent.callback()
        }

    }
}
#else
struct DocumentScanner: View {
    var documentsStore: DocumentImporter
    var callback: () -> ()

    var body: some View {
        Text("DocumentScanner not available")
            .onAppear { callback() }
    }
}
#endif
