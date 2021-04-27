import SwiftUI

struct DocumentNameInputView: View {
    @State private var newName: String = ""

    var cancel: () -> ()
    var setName: (String) -> ()

    var body: some View {
        VStack (alignment: .leading) {
            Text("Enter name").padding(.top)
            HStack {
                Image(systemName: "folder.fill").font(.title)
                TextField("New name", text: $newName).textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.vertical)

            HStack {
                Button(action: { cancel() }, label: {
                    Text("Cancel")
                })
                Spacer()
                Button(action: { setName(newName) }, label: {
                    Text("Save")
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
        DocumentNameInputView(cancel: {}, setName: { _ in })
            .previewLayout(.sizeThatFits)
            .padding()
            .preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
    }
}
