import SwiftUI

struct UserDefaultsEditView: View {
    var entry: UserDefaultsEntry
    var onSave: (Any) -> Void

    @State private var boolValue = false
    @State private var textValue = ""

    var body: some View {
        Form {
            if entry.value is Bool {
                Toggle("Value", isOn: $boolValue)
            } else {
                TextField("Value", text: $textValue)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            Button("Override") {
                var newVal: Any = entry.value
                if entry.value is Bool {
                    newVal = boolValue
                } else if entry.value is Int {
                    newVal = Int(textValue) ?? 0
                } else if entry.value is Double {
                    newVal = Double(textValue) ?? 0
                } else if entry.value is Float {
                    newVal = Float(textValue) ?? 0
                } else {
                    newVal = textValue
                }
                onSave(newVal)
            }
        }
        .navigationTitle(entry.key)
        .onAppear {
            if let boolVal = entry.value as? Bool {
                boolValue = boolVal
            } else {
                textValue = String(describing: entry.value)
            }
        }
    }
}

struct UserDefaultsEditView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UserDefaultsEditView(entry: UserDefaultsEntry(key: "Some", value: true), onSave: { _ in })
        }
    }
}
