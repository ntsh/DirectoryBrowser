import SwiftUI
import SQLite3

struct SQLiteTableView: View {
    let dbURL: URL
    let tableName: String

    @State private var rows: [[String: String]] = []
    @State private var columns: [String] = []
    @State private var errorMessage: String?

    var body: some View {
        List {
            if let errorMessage {
                Text(errorMessage)
            }
            ForEach(0..<rows.count, id: \..self) { index in
                let row = rows[index]
                VStack(alignment: .leading) {
                    ForEach(columns, id: \.self) { col in
                        HStack {
                            Text(col)
                            Spacer()
                            Text(row[col] ?? "")
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }
            }
        }
        .navigationTitle(tableName)
        .task { loadRows() }
    }

    private func loadRows() {
        rows.removeAll()
        columns.removeAll()
        var db: OpaquePointer?
        if sqlite3_open(dbURL.path, &db) != SQLITE_OK {
            if let db {
                errorMessage = String(cString: sqlite3_errmsg(db))
                sqlite3_close(db)
            } else {
                errorMessage = "Unable to open database"
            }
            return
        }
        defer { sqlite3_close(db) }

        let query = "SELECT * FROM \(tableName) LIMIT 50;"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            let columnCount = Int(sqlite3_column_count(stmt))
            for i in 0..<columnCount {
                if let cName = sqlite3_column_name(stmt, Int32(i)) {
                    columns.append(String(cString: cName))
                }
            }
            while sqlite3_step(stmt) == SQLITE_ROW {
                var row: [String: String] = [:]
                for i in 0..<columnCount {
                    let colName = columns[i]
                    if let cText = sqlite3_column_text(stmt, Int32(i)) {
                        row[colName] = String(cString: cText)
                    } else {
                        row[colName] = "NULL"
                    }
                }
                rows.append(row)
            }
            sqlite3_finalize(stmt)
        } else {
            errorMessage = "Query failed"
            sqlite3_finalize(stmt)
        }
    }
}
