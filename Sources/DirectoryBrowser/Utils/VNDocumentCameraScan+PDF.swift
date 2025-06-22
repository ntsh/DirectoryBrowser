#if os(iOS)
import Foundation
import VisionKit
import PDFKit

extension VNDocumentCameraScan {
    func exportPDF() -> URL? {
        let pdfDocument = PDFDocument()
        for index in 0..<pageCount {
            let image = imageOfPage(at: index)
            if let page = PDFPage(image: image) {
                pdfDocument.insert(page, at: pdfDocument.pageCount)
            }
        }
        guard let data = pdfDocument.dataRepresentation() else { return nil }
        let url = URL.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("pdf")
        do {
            try data.write(to: url)
            return url
        } catch {
            print("VNDocumentCameraScan: failed to write pdf \(error)")
            return nil
        }
    }
}
#endif
