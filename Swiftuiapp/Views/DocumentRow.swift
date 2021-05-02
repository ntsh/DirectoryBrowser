import SwiftUI

struct DocumentRow: View {
    var document: Document

    var body: some View {
        HStack (alignment: .top, spacing: 16) {
            ThumbnailView(url: document.url)
                .frame(width: 60, height: 60, alignment: .center)
                .clipped()
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 12 ) {
                Text(document.name)
                    .font(.headline)
                    .lineLimit(2)
                    .allowsTightening(true)

                if let created = document.modified {
                    Text("\(created, formatter: ShortTimestampFormatter)")
                        .font(.subheadline)
                        .lineLimit(1)
                        .allowsTightening(true)
                        .minimumScaleFactor(0.5)
                }
            }
        }
    }
}

struct DocumentRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DocumentRow(document: DocumentsStore_Preview(relativePath: "/", sorting: .date(ascending: true)).documents[1])
                .environment(\.sizeCategory, .large)
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.dark)

        }
    }
}
