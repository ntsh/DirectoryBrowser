import SwiftUI

struct SettingsView: View {
    @Binding var confirmDelete: Bool
    @Environment(\.presentationMode) private var presentation

    init(confirmDelete: Binding<Bool>) {
        self._confirmDelete = confirmDelete
    }

    var body: some View {
        NavigationView {
            Form {
                Toggle("Confirm Delete", isOn: $confirmDelete)
            }
            .navigationTitle("Settings")
#if os(iOS)
            .navigationBarItems(trailing: Button("Done") { presentation.wrappedValue.dismiss() })
#endif
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(confirmDelete: .constant(true))
    }
}
