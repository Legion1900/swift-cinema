import SwiftFMDB

struct MovieRecord: Table {

    static var TABLE_NAME: String { "Movies" }

    static let COLUMN_SERVICE_ID: String = "serviceId"
    static let COLUMN_TITLE: String = "title"
    static let COLUMN_OVERVIEW: String = "overview"
    static let COLUMN_RELEASE_DATE: String = "releaseDate"
    static let COLUMN_POSTER_PATH: String = "posterPath"
    static let COLUMN_AVERAGE_SCORE: String = "averageScore"

    static let createTableQuery: String = """
        CREATE TABLE IF NOT EXISTS \(TABLE_NAME) (
            \(COLUMN_SERVICE_ID) INTEGER PRIMARY KEY,
            \(COLUMN_TITLE) TEXT NOT NULL,
            \(COLUMN_OVERVIEW) TEXT NOT NULL,
            \(COLUMN_RELEASE_DATE) TEXT NOT NULL,
            \(COLUMN_POSTER_PATH) TEXT,
            \(COLUMN_AVERAGE_SCORE) REAL
        );
        """

    static func from(currentRow row: FMResultSet) throws(DbError) -> MovieRecord {
        guard let title = row.string(forColumn: COLUMN_TITLE),
            let overview = row.string(forColumn: COLUMN_OVERVIEW),
            let releaseDate = row.string(forColumn: COLUMN_RELEASE_DATE)
        else {
            throw DbError.databaseError(reason: "Failed to read MovieRecord from row")
        }

        let serviceId = row.int(forColumn: COLUMN_SERVICE_ID)
        let posterPath = row.string(forColumn: COLUMN_POSTER_PATH)
        let averageScore = row.double(forColumn: COLUMN_AVERAGE_SCORE)

        return MovieRecord(
            serviceId: serviceId,
            title: title,
            overview: overview,
            releaseDate: releaseDate,
            posterPath: posterPath,
            averageScore: averageScore
        )
    }

    let serviceId: Int
    let title: String
    let overview: String
    let releaseDate: String
    let posterPath: String?
    let averageScore: Double?
}
