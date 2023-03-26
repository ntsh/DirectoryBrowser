import Foundation

let ShortTimestampFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

let DocumentSizeFormatter: ByteCountFormatter = {
    let formatter = ByteCountFormatter()
    formatter.isAdaptive = false
    formatter.countStyle = .file
    return formatter
}()
