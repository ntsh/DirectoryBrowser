import SwiftUI

struct DocumentAttributeRow: View {
    var key, value: String

    var body: some View {
        HStack {
            Text(key)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
    }
}
struct DocumentAttributeRow_Previews: PreviewProvider {
    static var previews: some View {
        DocumentAttributeRow(key: "Size", value: "2.3 MB").padding()
    }
}
