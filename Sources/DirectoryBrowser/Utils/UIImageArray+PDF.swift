#if os(iOS)
import UIKit
import PDFKit

extension Array where Element == UIImage {
    func exportPDF() -> URL? {
        let pdfDocument = PDFDocument()
        for image in self {
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
            print("Array<UIImage>: failed to write pdf \(error)")
            return nil
        }
    }
}
#endif
