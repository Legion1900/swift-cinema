import Foundation
import SwiftFMDB

public protocol DbPathProvider {

    func getPathForDb(withName: String) -> String
}

public class MoviesStorage {

    private static let DB_NAME = "movies.db"
    private static let tables = [
        ImageConfigRecord.self
    ]

    private static func initTables() -> (FMDatabase) -> Void {
        { db in
            Self.tables.map { $0.createTableQuery }
                .forEach { sql in
                    db.executeStatements(sql)
                }
        }
    }

    private let dbPathprovider: DbPathProvider
    private let logger: Logger

    private let dbManager: DbManager

    public init(dbPathprovider: DbPathProvider, logger: Logger) {
        self.dbPathprovider = dbPathprovider
        self.logger = logger

        dbManager = DbManager(
            dbPathprovider: dbPathprovider,
            dbName: Self.DB_NAME,
            dbInitBlock: Self.initTables())
    }

    func update(imgConfig: ImageConfigRecord) async throws {
        try await dbManager.updateDb { db in
            let sql = """
                DELETE FROM \(ImageConfigRecord.tableName);
                INSERT INTO \(ImageConfigRecord.tableName) (\(ImageConfigRecord.COLUMN_BASE_URL), \(ImageConfigRecord.COLUMN_MAX_POSTER_SIZE))VALUES (:\(ImageConfigRecord.COLUMN_BASE_URL), :\(ImageConfigRecord.COLUMN_MAX_POSTER_SIZE));
                """
            db.executeUpdate(
                sql,
                withParameterDictionary: [
                    ImageConfigRecord.COLUMN_BASE_URL: imgConfig.baseUrl,
                    ImageConfigRecord.COLUMN_MAX_POSTER_SIZE: imgConfig.maxPosterSize,
                ])
        }
    }
}
