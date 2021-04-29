import SwiftUI

struct DocumentNameInputView: View {
    @State private var newName: String = ""
    @Binding var errorMessage: String?

    var heading: String
    var cancel: () -> ()
    var setName: (String) -> ()

    var body: some View {
        VStack (alignment: .leading) {
            Text(heading).padding(.top)
            HStack {
                TextField("Enter name", text: $newName).textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.vertical)

            if let errMsg = $errorMessage.wrappedValue {
                HStack {
                    Image(systemName: "exclamationmark.circle.fill")
                    Text(errMsg).font(.callout)
                }
                .foregroundColor(.red)
                .padding(.bottom)
            }

            HStack {
                Button(action: { cancel() }, label: {
                    HStack {
                        Image(systemName: "multiply.circle.fill")
                        Text("Cancel")
                    }
                })
                Spacer()
                Button(action: { setName(newName) }, label: {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Save")
                    }
                })
                .disabled($newName.wrappedValue.count == 0)
            }
            .padding(.bottom)
        }
        .background(Color.clear)
    }
}

struct DocumentNameInputView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentNameInputView(errorMessage: .constant("Folder exists"), heading: "Enter folder name", cancel: {}, setName: { _ in })
            .previewLayout(.sizeThatFits)
            .padding()
            .preferredColorScheme(.light)
    }
}
