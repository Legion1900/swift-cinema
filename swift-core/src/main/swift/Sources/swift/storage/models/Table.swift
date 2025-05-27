import SwiftFMDB

protocol Table {

    static var TABLE_NAME: String { get }
    static var createTableQuery: String { get }

    static func from(currentRow row: FMResultSet) throws(DbError) -> Self
}

extension Table {

    static func allFrom(resultSet: FMResultSet, expectedRowCount: Int = -1) throws(DbError)
        -> [Self]
    {
        var records: [Self] = []
        if expectedRowCount > 0 {
            records.reserveCapacity(expectedRowCount)
        }

        while resultSet.next() {
            let record = try from(currentRow: resultSet)
            records.append(record)
        }
        return records
    }
}
