import SwiftUI
import SQLite3

struct SQLiteBrowser: View {
    var url: URL

    @State private var tables: [String] = []
    @State private var errorMessage: String?

    var body: some View {
        List {
            if let errorMessage {
                Text(errorMessage)
            }
            ForEach(tables, id: \.self) { table in
                NavigationLink(table) {
                    SQLiteTableView(dbURL: url, tableName: table)
                }
            }
        }
        .navigationTitle(url.lastPathComponent)
        .task { loadTables() }
    }

    private func loadTables() {
        tables.removeAll()
        var db: OpaquePointer?
        if sqlite3_open(url.path, &db) != SQLITE_OK {
            if let db {
                errorMessage = String(cString: sqlite3_errmsg(db))
                sqlite3_close(db)
            } else {
                errorMessage = "Unable to open database"
            }
            return
        }
        defer { sqlite3_close(db) }

        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, "SELECT name FROM sqlite_master WHERE type='table';", -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                if let cStr = sqlite3_column_text(stmt, 0) {
                    let name = String(cString: cStr)
                    tables.append(name)
                }
            }
            sqlite3_finalize(stmt)
        } else {
            errorMessage = "Failed to query tables"
            sqlite3_finalize(stmt)
        }
    }
}
