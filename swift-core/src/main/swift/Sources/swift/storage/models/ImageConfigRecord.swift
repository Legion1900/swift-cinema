struct ImageConfigRecord: Table {

    static var tableName: String { "ImageConfig" }

    static var COLUMN_BASE_URL: String { "baseUrl" }
    static var COLUMN_MAX_POSTER_SIZE: String { "maxPosterSize" }

    static var createTableQuery: String {
        """
        CREATE TABLE IF NOT EXISTS \(tableName) (
            \(COLUMN_BASE_URL) TEXT NOT NULL,
            \(COLUMN_MAX_POSTER_SIZE) TEXT NOT NULL
        );
        """
    }

    let baseUrl: String
    let maxPosterSize: String
}
