import Foundation

struct UserDefaultsEntry: Identifiable {
    let key: String
    var value: Any
    var id: String { key }

    var displayValue: String {
        switch value {
        case let bool as Bool:
            return bool ? "true" : "false"
        case let str as String:
            return str
        default:
            return String(describing: value)
        }
    }
}
