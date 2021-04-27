import SwiftUI

struct DocumentNameInputView: View {
    @State private var newName: String = ""

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
        DocumentNameInputView(heading: "Enter folder name", cancel: {}, setName: { _ in })
            .previewLayout(.sizeThatFits)
            .padding()
            .preferredColorScheme(.light)
    }
}
