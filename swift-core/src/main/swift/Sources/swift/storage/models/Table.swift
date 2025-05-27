import SwiftFMDB

protocol Table {

    static var TABLE_NAME: String { get }
    static var createTableQuery: String { get }

    static func from(currentRow row: FMResultSet) throws(DbError) -> Self
}
