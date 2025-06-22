import SwiftUI

private struct ConfirmDeleteKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

public extension EnvironmentValues {
    var confirmDelete: Bool {
        get { self[ConfirmDeleteKey.self] }
        set { self[ConfirmDeleteKey.self] = newValue }
    }
}
