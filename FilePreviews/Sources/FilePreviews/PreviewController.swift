import SwiftUI
import QuickLook

public struct PreviewController: UIViewControllerRepresentable {
    public let url: URL
    @Binding var isPresented: Bool
    
    public init(url: URL, isPresented: Binding<Bool>) {
        self.url = url
        _isPresented = isPresented
    }

    public func makeUIViewController(context: Context) -> UINavigationController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done, target: context.coordinator, action: #selector(context.coordinator.dismiss)
        )

        let navigationController = UINavigationController(rootViewController: controller)
        return navigationController
    }

    public func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        return
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    public class Coordinator: QLPreviewControllerDataSource {
        let parent: PreviewController

        init(parent: PreviewController) {
            self.parent = parent
        }

        public func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }

        public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            return parent.url as NSURL
        }

        @objc func dismiss() {
            parent.isPresented = false
        }
    }
}
