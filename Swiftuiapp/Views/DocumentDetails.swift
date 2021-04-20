import SwiftUI

struct DocumentDetails: View {
    @State private var showingPreview = false
    var document: Document

    var body: some View {
        VStack {
            ThumbnailView(url: document.url)
                .frame(width: 400, height: 300, alignment: .center)
                .clipped()

            Text(document.name).font(.largeTitle).multilineTextAlignment(.leading)
            Text("\(document.date, formatter: itemFormatter)").font(.caption)

            Spacer()
            Button("Preview File") {
                        self.showingPreview = true
                    }
                    .sheet(isPresented: $showingPreview) {
                        PreviewController(url: document.url, isPresented: self.$showingPreview)
                    }
            Spacer()
        }
    }
}

struct DocumentDetails_Previews: PreviewProvider {
    static var previews: some View {
        DocumentDetails(document: DocumentsStore_Preview().documents[1])
            .preferredColorScheme(.dark)
            .environment(\.sizeCategory, .accessibilityExtraLarge)
    }
}


private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()
