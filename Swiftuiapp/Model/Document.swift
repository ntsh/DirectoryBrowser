import Foundation
import SwiftUI

struct Document: Identifiable {
    var id = UUID()

    var name: String
    var url: URL
    var date: Date
}
