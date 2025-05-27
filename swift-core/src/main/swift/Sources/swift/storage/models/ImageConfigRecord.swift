import SwiftFMDB

struct ImageConfigRecord: Table {

    static var TABLE_NAME: String { "ImageConfig" }

    static var COLUMN_BASE_URL: String { "baseUrl" }
    static var COLUMN_MAX_POSTER_SIZE: String { "maxPosterSize" }

    static var createTableQuery: String {
        """
        CREATE TABLE IF NOT EXISTS \(TABLE_NAME) (
            \(COLUMN_BASE_URL) TEXT NOT NULL,
            \(COLUMN_MAX_POSTER_SIZE) TEXT NOT NULL
        );
        """
    }

    static func from(currentRow row: SwiftFMDB.FMResultSet) throws(DbError) -> ImageConfigRecord {
        let baseUrl = row.string(forColumn: ImageConfigRecord.COLUMN_BASE_URL)
        let maxPosterSize = row.string(forColumn: ImageConfigRecord.COLUMN_MAX_POSTER_SIZE)

        guard let baseUrl = baseUrl, let maxPosterSize = maxPosterSize else {
            throw DbError.databaseError(
                reason:
                    "Failed to read ImageConfigRecord from row: baseUrl=\(String(describing: baseUrl)), maxPosterSize=\(String(describing: maxPosterSize))"
            )
        }

        return ImageConfigRecord(baseUrl: baseUrl, maxPosterSize: maxPosterSize)
    }

    let baseUrl: String
    let maxPosterSize: String
}
