import SwiftUI

struct UserDefaultsView: View {
    @State private var entries: [UserDefaultsEntry] = []

    var body: some View {
        List(entries) { entry in
            NavigationLink(destination: UserDefaultsEditView(entry: entry, onSave: { newValue in
                UserDefaults.standard.setValue(newValue, forKey: entry.key)
                load()
            })) {
                HStack {
                    Text(entry.key)
                    Spacer()
                    Text(entry.displayValue)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("User Defaults")
        .onAppear(perform: load)
    }

    private func load() {
        let dict = UserDefaults.standard.dictionaryRepresentation()
        entries = dict.map { UserDefaultsEntry(key: $0.key, value: $0.value) }
            .sorted { $0.key < $1.key }
    }
}

struct UserDefaultsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UserDefaultsView()
        }
    }
}
