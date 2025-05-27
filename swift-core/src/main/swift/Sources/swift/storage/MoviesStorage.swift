import Foundation
import SwiftFMDB

public protocol DbPathProvider {

    func getPathForDb(withName: String) -> String
}

public class MoviesStorage: Loggable {

    static var tag = "MoviesStorage"

    private static let DB_NAME = "movies.db"
    private static let tables = [
        ImageConfigRecord.self
    ]

    private static func initTables(_ db: FMDatabase, _ rollback: inout Bool) {
        let sqlStatements = Self.tables.map { $0.createTableQuery }
        var success = true
        for sql in sqlStatements {
            success = db.executeStatements(sql)

            if !success {
                break
            }
        }

        rollback = !success
    }

    private let dbPathprovider: DbPathProvider
    let logger: Logger

    private let dbManager: DbManager

    public init(dbPathprovider: DbPathProvider, logger: Logger) {
        self.dbPathprovider = dbPathprovider
        self.logger = logger

        dbManager = DbManager(
            dbPathprovider: dbPathprovider,
            dbName: Self.DB_NAME,
            dbInitBlock: Self.initTables
        )
    }

    func update(imgConfig: ImageConfigRecord) async throws {
        try await dbManager.transaction { db, rollback in

            db.executeUpdate(cached: true, "DELETE FROM \(ImageConfigRecord.tableName);")

            let success = db.executeUpdate(
                cached: true,
                "INSERT INTO \(ImageConfigRecord.tableName) (\(ImageConfigRecord.COLUMN_BASE_URL), \(ImageConfigRecord.COLUMN_MAX_POSTER_SIZE)) VALUES (?, ?);",
                withArgumentsInArray: [imgConfig.baseUrl, imgConfig.maxPosterSize])

            rollback = !success
        }
    }
}
